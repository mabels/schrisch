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
    this.onRender = this.onRender.bind(this);
    this.onWebGLRender = this.onWebGLRender.bind(this);
    this.onResize = this.onResize.bind(this);
    this.onSend = this.onSend.bind(this);
    this.element = document.createElement('canvas');
    this.parent = rap.getObject(properties.parent);
    this.parent.addListener('Resize', this.onResize);
    this.parent.append(this.element);
    rap.on('render', this.onRender);
  }
  
  onRender() {
    if (this.element.parentNode) {
      rap.off('render', this.onRender);

      this.onResize();
      this.engine = new BABYLON.Engine(this.element, true);
      this.engine.renderEvenInBackground = false;
      this.scene = new BABYLON.Scene(this.engine);
      this.scene.clearColor = new BABYLON.Color3(0.8, 0.8, 0.8);
      this.camera = new BABYLON.ArcRotateCamera('camera1', 0, -1800, -6000, new BABYLON.Vector3(1000, 1500,0), this.scene);
      this.camera.attachControl(this.element, false);
      this.light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0.8, 0.8, 0.8), this.scene);
      this.light.intensity = .5;

      Models.createRack('xxxx', 0, 0, this.scene);
      Models.createRack('xxx2', 600, 0, this.scene);
//      var ground = BABYLON.Mesh.CreateGround('ground1', 2000, 2000, 2, this.scene);
      this.engine.runRenderLoop(this.onWebGLRender);

      rap.on('send', this.onSend);
    }
  }
  
  onWebGLRender() {
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
