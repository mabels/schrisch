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
  }
  
  onRenderRWT() {
    if (this.element.parentNode) {
      rap.off('render', this.onRenderRWT);

      this.onResize();
      this.engine = new BABYLON.Engine(this.element, true);
      this.engine.renderEvenInBackground = false;
      this.scene = new BABYLON.Scene(this.engine);
      this.scene.clearColor = new BABYLON.Color3(0.8, 0.8, 0.8);
      this.camera = new BABYLON.FreeCamera('free-cam', new BABYLON.Vector3(0, 1500.0, -4000.0), this.scene);
      this.camera.setTarget(new BABYLON.Vector3(0, 500.0, 0));
      this.camera.attachControl(this.element, false);
      this.light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0.8, 0.8, 0.8), this.scene);
      this.light.intensity = .5;

      var ground = BABYLON.Mesh.CreateGround('ground1', 2000, 2000, 2, this.scene);
      Models.createRack('xxxx', 0, 0, this.scene);
      //Models.createRack('xxx2', 600, 0, this.scene);
      
      window.SCENE = this.scene;
      requestAnimationFrame(this.onRenderWebGL);

      rap.on('send', this.onSend);
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
