(function() {
  'use strict';

  /**
   * Code based on:
   * https://github.com/eclipsesource/rap-ckeditor/blob/master/com.eclipsesource.widgets.ckeditor/src/resources/handler.js
   */

  rap.registerTypeHandler('s2.BabylonJS', {
    factory : function(properties) {
      return new s2.BabylonJS(properties);
    },
    destructor : 'destroy',
    properties : []
  });

  window.s2 = window.s2 || {};

  s2.BabylonJS = function(properties) {
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

  s2.BabylonJS.prototype = {
    onRender : function() {
      if (this.element.parentNode) {
        rap.off('render', this.onRender);

        this.onResize();
        this.engine = new BABYLON.Engine(this.element, true);
        this.scene = new BABYLON.Scene(this.engine);
        this.scene.clearColor = new BABYLON.Color3(0, 1, 0);
        this.camera = new BABYLON.FreeCamera('camera1', new BABYLON.Vector3(0,
            5, -10), this.scene);
        this.camera.setTarget(BABYLON.Vector3.Zero());
        this.camera.attachControl(this.element, false);
        this.light = new BABYLON.HemisphericLight('light1',
            new BABYLON.Vector3(0, 1, 0), this.scene);
        this.light.intensity = .5;
        var sphere = BABYLON.Mesh.CreateSphere('sphere1', 16, 2, this.scene);
        sphere.position.y = 1;
        var ground = BABYLON.Mesh.CreateGround('ground1', 6, 6, 2, this.scene);
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
}());
