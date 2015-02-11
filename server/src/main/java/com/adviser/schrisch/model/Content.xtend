package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

@Observable
class Content extends Base {

  @Editable
  String name

  @Editable
  String label

  @Editable
  String asset_no

  @Editable
  String type

  @Editable
  String tags

  @Editable
  boolean has_problems

  @Editable
  String id

  var Spaces spaces
  var Ports ports
  var Ips ips
  var Attributes attributes

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
    spaces = new Spaces(pcls)
    spaces.parent = this
    ports = new Ports(pcls)
    ports.parent = this
    ips = new Ips(pcls)
    ips.parent = this
    attributes = new Attributes(pcls)
    attributes.parent = this
  }

  static def create(PropertyChangeListener[] pcls, String name, String label, String asset_no, String type,
    String tags, boolean has_problems, String id) {
    val ct = new Content(pcls)
    ct.setName(name)
    ct.setLabel(label)
    ct.setAsset_no(asset_no)
    ct.setType(type)
    ct.setTags(tags)
    ct.setHas_problems(has_problems)
    ct.setId(id)
    return ct
  }

  override getIdent() {
    Utils.clean_fname(
      if (name != null && !name.trim.empty) {
        name.trim
      } else {
        id ?: '' + super.ident
      }
    )
  }

}
