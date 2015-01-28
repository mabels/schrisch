package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonIgnore

@Accessors
class Rack extends Base implements Cloneable {
  String name
  String height
  String comment
  String row

  @JsonIgnore
  val contents = new Contents()

  static def create(String name, int height, String comment, String row) {
  	val my = new Rack()
    my.name = name
    my.height = "" + height
    my.comment = comment
    my.row = row
    return my
  }

  public override Rack clone() {
    super.clone as Rack
  }

  override getIdent() {
    Utils.clean_fname(row + "-" + name)
  }

  override int hashCode() {
    val prime = 31
    var result = 1
    result = prime * result + if(name == null) 0 else name.hashCode()
    return result
  }

  override equals(Object obj) {
    if(this === obj) return true
    if(obj === null) return false
    if(class !== obj.class) return false
    val other = obj as Rack
    if(name != other.name) return false
    return true
  }

}
