"use strict";

/**
 * Code based on:
 * https://github.com/eclipsesource/rap-ckeditor/blob/master/com.eclipsesource.widgets.ckeditor/src/resources/handler.js
 */

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

var rackFactory = function(name, pos_x, pos_z, scene) {
  var foot = BABYLON.Mesh.CreateBox(name+'-foot', 1, scene);
  foot.scaling.x = 600;
  foot.scaling.y = 100;
  foot.scaling.z = 1100;
  foot.position.x = foot.scaling.x/2 + pos_x
  foot.position.y = foot.scaling.y/2
  foot.position.z = foot.scaling.z/2 + pos_z;
  
  [[0,0],[0,1100-58.7],[600-58.7, 1100-58.7],[600-58.7,0]].forEach(function(i, idx) {
    console.log(i)
    var pile = BABYLON.Mesh.CreateBox(name+'-pile-'+idx, 1, scene);
    pile.scaling.x = 58.7
    pile.scaling.z = 58.7
    pile.scaling.y = 1866.9
    pile.position.x = pile.scaling.x/2 + i[0] + pos_x
    pile.position.z = pile.scaling.z/2 + i[1]
    pile.position.y = pile.scaling.y/2 + 100 + pos_z
  })

  var foot = BABYLON.Mesh.CreateBox(name+'-head', 1, scene);
  foot.scaling.x = 600;
  foot.scaling.y = 100
  foot.scaling.z = 1100;
  foot.position.x = foot.scaling.x/2 + pos_x
  foot.position.y = foot.scaling.y/2+1866.9+100;
  foot.position.z = foot.scaling.z/2 + pos_z
}

var BabylonWidget = function(properties) {
  this.onRender = this.onRender.bind(this);
  this.onWebGLRender = this.onWebGLRender.bind(this);
  this.onResize = this.onResize.bind(this);
  this.onSend = this.onSend.bind(this);
  this.element = document.createElement('canvas');
  this.parent = rap.getObject(properties.parent);
  this.parent.addListener('Resize', this.onResize);
  this.parent.append(this.element);
  rap.on('render', this.onRender);
};

BabylonWidget.prototype = {
  onRender : function() {
    if (this.element.parentNode) {
      rap.off('render', this.onRender);

      this.onResize();
      var engine =  this.engine = new BABYLON.Engine(this.element, true);
      var scene = this.scene = new BABYLON.Scene(this.engine);
      this.scene.clearColor = new BABYLON.Color3(0.8, 0.8, 0.8);
      this.camera = new BABYLON.ArcRotateCamera('camera1', 0, -1800, -6000, new BABYLON.Vector3(1000, 1500,0), this.scene);
      this.camera.attachControl(this.element, false);
      this.light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0.8, 0.8, 0.8), this.scene);
      this.light.intensity = .5;

      rackFactory('xxxx', 0, 0, this.scene);
      rackFactory('xxx2', 600, 0, this.scene);
//        this.scene.debugLayer.show();
//        var ground = BABYLON.Mesh.CreateGround('ground1', 2000, 2000, 2, this.scene);
      this.engine.runRenderLoop(this.onWebGLRender);

      rap.on('send', this.onSend);
    }
  },

  onWebGLRender : function() {
    this.scene.render();
  },

  onResize : function() {
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
  },

  onSend : function() {
  },

  destroy : function() {
    rap.off('send', this.onSend);
    this.element.parentNode.removeChild(this.element);
  }
};

module.exports.inRapRuntime = inRapRuntime;
module.exports.register = register;
module.exports.BabylonWidget = BabylonWidget;
