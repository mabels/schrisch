const RACK_UNIT = 4.445; // cm
const RACK_WIDTH = 60.0; // cm
const RACK_DEPTH = 110.0; // cm
const RACK_BORDER = 2.0; // cm

function createRack(name, units, scene) {
  let mat = new BABYLON.StandardMaterial(name + '-material', scene);
  mat.diffuseColor = new BABYLON.Color3(0.6, 0.6, 0.6);
  
  let foot = BABYLON.Mesh.CreateBox(name + '-foot', 1, scene);
  foot.material = mat;
  foot.scaling = new BABYLON.Vector3(RACK_WIDTH, RACK_BORDER, RACK_DEPTH);
  foot.position = new BABYLON.Vector3(0.0, RACK_BORDER / 2.0, 0.0);
  
  let pile1 = BABYLON.Mesh.CreateBox(name + '-pile-1', 1, scene);
  pile1.material = mat;
  pile1.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile1.position = new BABYLON.Vector3(-(RACK_WIDTH / 2.0) + 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), -(RACK_DEPTH / 2.0) + 1.0);
  
  let pile2 = BABYLON.Mesh.CreateBox(name + '-pile-2', 1, scene);
  pile2.material = mat;
  pile2.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile2.position = new BABYLON.Vector3((RACK_WIDTH / 2.0) - 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), -(RACK_DEPTH / 2.0) + 1.0);
  
  let pile3 = BABYLON.Mesh.CreateBox(name + '-pile-3', 1, scene);
  pile3.material = mat;
  pile3.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile3.position = new BABYLON.Vector3((RACK_WIDTH / 2.0) - 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), (RACK_DEPTH / 2.0) - 1.0);
  
  let pile4 = BABYLON.Mesh.CreateBox(name + '-pile-4', 1, scene);
  pile4.material = mat;
  pile4.scaling = new BABYLON.Vector3(RACK_BORDER, units * RACK_UNIT, RACK_BORDER);
  pile4.position = new BABYLON.Vector3(-(RACK_WIDTH / 2.0) + 1.0, RACK_BORDER + (units * RACK_UNIT / 2.0), (RACK_DEPTH / 2.0) - 1.0);
  
  let top = BABYLON.Mesh.CreateBox(name + '-top', 1, scene);
  top.material = mat;
  top.scaling = new BABYLON.Vector3(RACK_WIDTH, RACK_BORDER, RACK_DEPTH);
  top.position = new BABYLON.Vector3(0.0, RACK_BORDER + units * RACK_UNIT, 0.0);
  
  let node = new BABYLON.Mesh(name + '-node', scene);
  node.position = new BABYLON.Vector3(RACK_WIDTH / 2.0, RACK_BORDER / 2.0, RACK_DEPTH / 2.0);
  foot.parent = node;
  pile1.parent = node;
  pile2.parent = node;
  pile3.parent = node;
  pile4.parent = node;
  top.parent = node;

  let tex = new BABYLON.DynamicTexture(name + '-text-texture', 512, scene, true);
  tex.hasAlpha = true;
  tex.drawText(name, null, RACK_WIDTH * 4, '32px sans-serif', 'black', 'transparent', true);
  var plane =  BABYLON.Mesh.CreatePlane(name + "-TextPlane", RACK_WIDTH * 2, scene, true);
  plane.material = new BABYLON.StandardMaterial(name + "TextPlaneMaterial", scene);
  plane.material.backFaceCulling = false;
  plane.material.specularColor = new BABYLON.Color3(0, 0, 0);
  plane.material.diffuseTexture = tex;
  plane.parent = node;
  plane.position.y = RACK_BORDER + units * RACK_UNIT;
  plane.position.z = -RACK_DEPTH / 2.0;
  
  let root = new BABYLON.Mesh(name, scene);
  root.label = name;
  node.parent = root;

  return root;
}

function createDevice(name, unit, units, scene) {
  let mat = new BABYLON.StandardMaterial(name + '-material', scene);
  let col = (unit / 47.0 / 2.0) + 0.25;
  mat.diffuseColor = new BABYLON.Color3(col, col / 2.0, col / 2.0);

  let box = BABYLON.Mesh.CreateBox(name + '-foot', 1, scene);
  box.material = mat;
  box.scaling = new BABYLON.Vector3(RACK_WIDTH - 2.0, (RACK_UNIT * units) - 1.0, RACK_DEPTH - 2.0);
  box.position = new BABYLON.Vector3(RACK_WIDTH / 2.0, 0.5, RACK_DEPTH / 2.0);

  let tex = new BABYLON.DynamicTexture(name + '-text-texture', 512, scene, true);
  tex.hasAlpha = true;
  tex.drawText(name, null, RACK_WIDTH * 4, '32px sans-serif', 'white', 'transparent', true);
  var plane =  BABYLON.Mesh.CreatePlane(name + "-TextPlane", RACK_WIDTH, scene, true);
  plane.material = new BABYLON.StandardMaterial(name + "TextPlaneMaterial", scene);
  plane.material.backFaceCulling = false;
  plane.material.specularColor = new BABYLON.Color3(1, 1, 1);
  plane.material.diffuseTexture = tex;
  plane.position.x = RACK_WIDTH / 2.0;
  plane.position.y = -(RACK_UNIT * units) / 2.0;
  
  let root = new BABYLON.Mesh(name, scene);
  root.label = name;
  box.parent = root;
  plane.parent = root;

  return root;
}

module.exports.RACK_UNIT = RACK_UNIT;
module.exports.RACK_WIDTH = RACK_WIDTH;
module.exports.RACK_DEPTH = RACK_DEPTH;
module.exports.createRack = createRack;
module.exports.createDevice = createDevice;
