function createRack(name, pos_x, pos_z, scene) {
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

module.exports.createRack = createRack;
