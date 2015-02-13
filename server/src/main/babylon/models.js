const RACK_UNIT = 4.826; // cm
const RACK_WIDTH = 60.0; // cm
const RACK_DEPTH = 60.0; // cm
const RACK_BORDER = 2.0; // cm

function createRack(name, units, scene) {
  var mat = new BABYLON.StandardMaterial(name + '-material', scene);
  mat.diffuseColor = new BABYLON.Color3(0.6, 0.6, 0.6);
  
  var foot = BABYLON.Mesh.CreateBox(name + '-foot', 1, scene);
  foot.material = mat;
  foot.scaling = new BABYLON.Vector3(RACK_WIDTH, RACK_BORDER, RACK_DEPTH);
  foot.position = new BABYLON.Vector3(0.0, RACK_BORDER / 2.0, 0.0);
  
  var pile1 = BABYLON.Mesh.CreateBox(name + '-pile-1', 1, scene);
  pile1.material = mat;
  pile1.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile1.position = new BABYLON.Vector3(-(RACK_WIDTH / 2.0) + 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), -(RACK_WIDTH / 2.0) + 1.0);
  
  var pile2 = BABYLON.Mesh.CreateBox(name + '-pile-2', 1, scene);
  pile2.material = mat;
  pile2.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile2.position = new BABYLON.Vector3((RACK_WIDTH / 2.0) - 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), -(RACK_WIDTH / 2.0) + 1.0);
  
  var pile3 = BABYLON.Mesh.CreateBox(name + '-pile-3', 1, scene);
  pile3.material = mat;
  pile3.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile3.position = new BABYLON.Vector3((RACK_WIDTH / 2.0) - 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), (RACK_WIDTH / 2.0) - 1.0);
  
  var pile4 = BABYLON.Mesh.CreateBox(name + '-pile-4', 1, scene);
  pile4.material = mat;
  pile4.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile4.position = new BABYLON.Vector3(-(RACK_WIDTH / 2.0) + 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), (RACK_WIDTH / 2.0) - 1.0);
  
  var top = BABYLON.Mesh.CreateBox(name + '-top', 1, scene);
  top.material = mat;
  top.scaling = new BABYLON.Vector3(RACK_WIDTH, RACK_BORDER, RACK_DEPTH);
  top.position = new BABYLON.Vector3(0.0, RACK_BORDER + units * RACK_UNIT, 0.0);
  
  var node = new BABYLON.Mesh(name + '-node', scene);
  node.position = new BABYLON.Vector3(RACK_WIDTH / 2.0, RACK_BORDER / 2.0, RACK_DEPTH / 2.0);
  foot.parent = node;
  pile1.parent = node;
  pile2.parent = node;
  pile3.parent = node;
  pile4.parent = node;
  top.parent = node;

  var root = new BABYLON.Mesh(name, scene);
  node.parent = root;

  return root;
}

module.exports.createRack = createRack;
