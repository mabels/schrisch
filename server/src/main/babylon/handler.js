"use strict";

/**
 * Code based on:
 * https://github.com/eclipsesource/rap-ckeditor/blob/master/com.eclipsesource.widgets.ckeditor/src/resources/handler.js
 */
require('array.prototype.find');
var Models = require('./models.js');

var inRapRuntime = typeof(global.rap) !== 'undefined';

function register(mock) {
  if (inRapRuntime) {
    rap.registerTypeHandler('BabylonWidget', {
      factory : function(properties) {
        return new BabylonWidget(properties);
      },
      destructor : 'destroy',
      properties : ['dataCenter', 'selectedRack', 'enabled']
    });
  } else {
    global.rap = mock.rap;
    new BabylonWidget(mock.properties);
  }
}

class BabylonWidget {

  constructor(properties) {
    try {
      this.enabled = true;
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
        if (e.keyCode == 65 /* a */) {
          dir.x = -5.0;
        }
        if (e.keyCode == 68 /* d */) {
          dir.x = 5.0;
        }
        if (e.keyCode == 87 /* w */) {
          dir.z = 5.0;
        }
        if (e.keyCode == 83 /* s */) {
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
      this.camera.attachControl(this.element, false);

      this.light0 = new BABYLON.HemisphericLight('light0', new BABYLON.Vector3(0.8, 0.8, 0.8), this.scene);
      this.light0.intensity = .5;
      this.light1 = new BABYLON.DirectionalLight('light1', new BABYLON.Vector3(-1, -1, 1), this.scene);
      this.light1.diffuse = new BABYLON.Color3(0.8, 0.8, 0.8);

      var ground = BABYLON.Mesh.CreateGround('ground', 50000, 50000, 2, this.scene);
      ground.mat = new BABYLON.StandardMaterial('ground-material', this.scene);
      ground.mat.diffuseColor = new BABYLON.Color3(0.2, 0.2, 0.2);

      // TODO: Remove this global
      window.SCENE = this.scene;
      requestAnimationFrame(this.onRenderWebGL);

      rap.on('send', this.onSend);
    }
  }

  onRenderWebGL() {
    if (this.enabled) {
      this.scene.render();
    }
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

  setDataCenter(dataCenter) {
    // Cleanup mess...
    if (this.dataCenter) {
      this.dataCenter.racks.forEach((rack, i) => {
        rack.object.dispose();
      });
    }
    this.dataCenter = JSON.parse(dataCenter);
    // ... and build up new
    this.dataCenter.racks.forEach((rack, i) => {
      let glRack = Models.createRack(rack.ident, rack.height, this.scene);
      glRack.position = new BABYLON.Vector3((Models.RACK_WIDTH + 20) * i, 0, 400);
      rack.object = glRack;
      rack.contents.forEach((content) => {
        if (content.spaces.collection.length > 0) {
          let glDevice = Models.createDevice(content.label, content.spaces.collection[0].unit_no, 1, this.scene);
          glDevice.parent = glRack;
          glDevice.position = new BABYLON.Vector3(0, content.spaces.collection[0].unit_no * Models.RACK_UNIT, 0);
          content.object = glDevice;
        }
      });
    });
    this.camera.position = new BABYLON.Vector3(0, 180.0, -150.0);
    requestAnimationFrame(this.onRenderWebGL);
  }
  
  setSelectedRack(rackOid) {
    let rack = this.dataCenter.racks.find((rack) => rack.objectId === rackOid);
    this.camera.position.x = rack.object.position.x + Models.RACK_WIDTH / 2.0;
    this.camera.position.z = rack.object.position.z - 400;
    this.camera.rotation = rack.object.rotation.negate();
    this.camera._reset();
  }
  
  setEnabled(enabled) {
    this.enabled = enabled;
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
