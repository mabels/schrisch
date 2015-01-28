package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonIgnore

@Accessors
class DataCenter extends Base {
  String name
  String street
  String zipCode
  String city
  String country
  @JsonIgnore val racks = new Racks()

  override getIdent() {
    if(name != null) {
      name
    } else {
      name = "" + hashCode
    }
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
    val other = obj as DataCenter
    if(name != other.name) return false
    return true
  }

}
