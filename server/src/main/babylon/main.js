var RAP = require('./handler.js');

if (!RAP.inRapRuntime) {
  var dom = document.body;
  var handler = {};
  var mock = {
    rap: {
      getObject: function(object) {
        return object;
      },
      on: function(name, fn) {
        if (typeof(fn) !== 'undefined') {
          handler[name] = fn;
        } else {
          handler[name] && handler[name]();
        }
      },
      off: function(name) {
        handler[name] = null;
      }
    },
    properties: {
      parent: {
        addListener: function(name, fn) {
          if (name == 'Resize') {
            window.onresize = fn;
          }
        },
        append: function(element) {
          dom.appendChild(element);
        },
        getClientArea: function() {
          return [0, 0, window.innerWidth, window.innerHeight];
        }
      }
    }
  };
}
RAP.register(mock);
if (!RAP.inRapRuntime) {
  mock.rap.on('render');
}
