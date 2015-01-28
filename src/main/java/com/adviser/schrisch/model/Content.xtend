package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Content extends Base {
  String name
  String label
  String asset_no
  String type
  String tags
  boolean has_problems
  String id

  var Spaces spaces = new Spaces
  var Ports ports = new Ports
  var Ips ips = new Ips
  var Attributes attributes = new Attributes

  
  static def create(String name, String label, String asset_no, String type, String tags, boolean has_problems, String id) {
    val ct = new Content()
    ct.name = name
    ct.label = label
    ct.asset_no = asset_no
    ct.type = type
    ct.tags = tags
    ct.has_problems = has_problems
    ct.id = id
    return ct
  }

  override getIdent() {
    Utils.clean_fname(
      if(name != null && !name.trim.empty) {
        name.trim
      } else {
        id
      }
    )
  }

  override int hashCode() {
    val prime = 31
    var result = 1
    result = prime * result + if(id == null) 0 else id.hashCode()
    return result
  }

  override equals(Object obj) {
    if(this === obj) return true
    if(obj === null) return false
    if(class !== obj.class) return false
    val other = obj as Content
    if(id != other.id) return false
    return true
  }

}
