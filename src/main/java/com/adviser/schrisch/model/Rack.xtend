package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonIgnore

@Accessors
class Rack extends Base<DataCenter> implements Cloneable {
  String name
  String height
  String comment
  String row

  @JsonIgnore
  val contents = new Contents(this)

  new(String name, int height, String comment, String row) {
    this.name = name
    this.height = "" + height
    this.comment = comment
    this.row = row
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
