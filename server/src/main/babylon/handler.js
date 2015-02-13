"use strict";

/**
 * Code based on:
 * https://github.com/eclipsesource/rap-ckeditor/blob/master/com.eclipsesource.widgets.ckeditor/src/resources/handler.js
 */
var Models = require('./models.js');

var inRapRuntime = typeof(global.rap) !== 'undefined';

function register(mock) {
  if (inRapRuntime) {
    rap.registerTypeHandler('BabylonWidget', {
      factory : function(properties) {
        return new BabylonWidget(properties);
      },
      destructor : 'destroy',
      properties : []
    });
  } else {
    global.rap = mock.rap;
    new BabylonWidget(mock.properties);
  }
}

class BabylonWidget {

  constructor(properties) {
    try {
      this.onRenderRWT = this.onRenderRWT.bind(this);
      this.onRenderWebGL = this.onRenderWebGL.bind(this);
      this.onResize = this.onResize.bind(this);
      this.onSend = this.onSend.bind(this);
      
      this.element = document.createElement('canvas');
      this.parent = rap.getObject(properties.parent);
      this.parent.addListener('Resize', this.onResize);
      this.parent.append(this.element);
      
      this.setupRendering();
      rap.on('render', this.onRenderRWT);
    } catch (e) {
      console.error(e);
      throw e;
    }
  }
  
  setupRendering() {
    var dragEnabled = false;
    this.element.addEventListener('mousedown', () => dragEnabled = true);
    this.element.addEventListener('mousemove', () => dragEnabled && requestAnimationFrame(this.onRenderWebGL));
    this.element.addEventListener('mouseup', () => dragEnabled = false);
    this.element.addEventListener('wheel', (e) => {
      var dir = BABYLON.Vector3.Zero();
      var transformedDirection = BABYLON.Vector3.Zero();
      dir.copyFromFloats(0, 0, e.wheelDelta / 10.0);
      this.camera.getViewMatrix().invertToRef(this.camera._cameraTransformMatrix);
      BABYLON.Vector3.TransformNormalToRef(dir, this.camera._cameraTransformMatrix, transformedDirection);
      transformedDirection.y = 0;
      this.camera.position.addInPlace(transformedDirection);
      
      requestAnimationFrame(this.onRenderWebGL);
    });
    
    var inCanvas = false;
    this.element.addEventListener('mouseenter', () => inCanvas = true);
    this.element.addEventListener('mouseleave', () => inCanvas = false);
    document.addEventListener('keydown', (e) => {
      if (inCanvas) {
        var dir = BABYLON.Vector3.Zero();
        var transformedDirection = BABYLON.Vector3.Zero();
        if (e.keyCode == 65 /*a*/) {
          dir.x = -5.0;
        }
        if (e.keyCode == 68 /*d*/) {
          dir.x = 5.0;
        }
        if (e.keyCode == 87 /*w*/) {
          dir.z = 5.0;
        }
        if (e.keyCode == 83 /*s*/) {
          dir.z = -5.0;
        }
        this.camera.getViewMatrix().invertToRef(this.camera._cameraTransformMatrix);
        BABYLON.Vector3.TransformNormalToRef(dir, this.camera._cameraTransformMatrix, transformedDirection);
        transformedDirection.y = 0;
        this.camera.position.addInPlace(transformedDirection);
        
        requestAnimationFrame(this.onRenderWebGL);
      }
    });
  }
  
  onRenderRWT() {
    if (this.element.parentNode) {
      rap.off('render', this.onRenderRWT);

      this.onResize();
      this.engine = new BABYLON.Engine(this.element, true);
      this.engine.renderEvenInBackground = false;
      this.scene = new BABYLON.Scene(this.engine);
      this.scene.clearColor = new BABYLON.Color3(1.0, 1.0, 1.0);
      this.camera = new BABYLON.FreeCamera('free-cam', new BABYLON.Vector3(0, 180.0, -150.0), this.scene);
      //this.camera.setTarget(new BABYLON.Vector3(0, 150.0, 0));
      this.camera.attachControl(this.element, false);

      this.light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0.8, 0.8, 0.8), this.scene);
      this.light.intensity = .5;

      var ground = BABYLON.Mesh.CreateGround('ground', 50000, 50000, 2, this.scene);

      // TODO: Test data...
      var rack40he = Models.createRack('xx1', 40, this.scene);
      rack40he.position = new BABYLON.Vector3(0, 0, 0);
      var rack47he = Models.createRack('xx2', 47, this.scene);
      rack47he.position = new BABYLON.Vector3(61, 0, 0);
      var rack45he = Models.createRack('xx3', 45, this.scene);
      rack45he.position = new BABYLON.Vector3(-61, 0, 0);

      var rack40he = Models.createRack('xx4', 40, this.scene);
      rack40he.position = new BABYLON.Vector3(0, 0, 260);
      var rack47he = Models.createRack('xx5', 47, this.scene);
      rack47he.position = new BABYLON.Vector3(61, 0, 260);
      var rack45he = Models.createRack('xx6', 45, this.scene);
      rack45he.position = new BABYLON.Vector3(-61, 0, 260);

      // TODO: Remove this global

      // generate drawing canvas
      this.drawingCanvas = document.createElement("canvas");
      this.drawingCanvas.id = "DebugLayerDrawingCanvas";
      this.drawingCanvas.style.position = "absolute";
      this.drawingCanvas.style.pointerEvents = "none";
      this.drawingContext = this.drawingCanvas.getContext("2d");
      this.element.parentNode.appendChild(this.drawingCanvas);

      this.calculateDrawing();
      this.scene.registerAfterRender(this.syncDrawing.bind(this));

      window.SCENE = this.scene;
      requestAnimationFrame(this.onRenderWebGL);

      rap.on('send', this.onSend);
    }
  }

  calculateDrawing() {
    this.drawingCanvas.style.left = "0px";
    this.drawingCanvas.style.top = "0px";
    this.drawingCanvas.style.width = this.engine.getRenderWidth() + "px";
    this.drawingCanvas.style.height = this.engine.getRenderHeight() + "px";

    this.drawingCanvas.width = this.engine.getRenderWidth();
    this.drawingCanvas.height = this.engine.getRenderHeight();
  }

  syncDrawing() {
    this.drawingContext.clearRect(0, 0, this.drawingCanvas.width, this.drawingCanvas.height);
    var engine = this.engine;
    var viewport = this.scene.activeCamera.viewport;
    var globalViewport = viewport.toGlobal(engine);

    // Meshes
    var meshes = this.scene.getActiveMeshes();
    for (var index = 0; index < meshes.length; index++) {
      var mesh = meshes.data[index];
      if(mesh.name.match(/(foot|pile|top)/)) {
        var position = mesh.getBoundingInfo().boundingSphere.center;
        var projectedPosition = BABYLON.Vector3.Project(
          position,
          mesh.getWorldMatrix(),
          this.scene.getTransformMatrix(),
          globalViewport);
        this.renderLabel(mesh.name, projectedPosition, 12, 'black');
      }
    }
  }

  renderLabel(text, projectedPosition, labelOffset, color) {
    if (projectedPosition.z > 0 && projectedPosition.z < 1.0) {
      this.drawingContext.font = "normal 12px Segoe UI";
      var textMetrics = this.drawingContext.measureText(text);
      var centerX = projectedPosition.x - textMetrics.width / 2;
      var centerY = projectedPosition.y;
      this.drawingContext.beginPath();
      this.drawingContext.rect(centerX - 5, centerY - labelOffset, textMetrics.width + 10, 17);
      this.drawingContext.fillStyle = color;
      this.drawingContext.globalAlpha = 0.5;
      this.drawingContext.fill();
      this.drawingContext.globalAlpha = 1.0;
      this.drawingContext.strokeStyle = '#FFFFFF';
      this.drawingContext.lineWidth = 1;
      this.drawingContext.stroke();
      this.drawingContext.fillStyle = "#FFFFFF";
      this.drawingContext.fillText(text, centerX, centerY);
      this.drawingContext.beginPath();
      this.drawingContext.arc(projectedPosition.x, centerY, 2, 0, 2 * Math.PI, false);
      this.drawingContext.fill();
    }
  }

  onRenderWebGL() {
    console.log('render new frame')
    this.scene.render();
  }

  onResize() {
    if (this.parent) {
      var area = this.parent.getClientArea();
      this.element.style.left = area[0] + 'px';
      this.element.style.top = area[1] + 'px';
      this.element.style.width = area[2] + 'px';
      this.element.style.height = area[3] + 'px';
    }
    if (this.engine) {
      this.engine.resize();
      requestAnimationFrame(this.onRenderWebGL);
    }
  }

  onSend() {
  }

  destroy() {
    this.engine.stopRenderLoop(this.onWebGLRender);
    rap.off('send', this.onSend);
    this.element.parentNode.removeChild(this.element);
  }
}

module.exports.inRapRuntime = inRapRuntime;
module.exports.register = register;
module.exports.BabylonWidget = BabylonWidget;
