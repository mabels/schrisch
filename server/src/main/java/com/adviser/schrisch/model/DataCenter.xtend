package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonIgnore
import java.beans.PropertyChangeListener

@Observable
class DataCenter extends Base {

  @Editable
  String name

  @Editable
  String street

  @Editable
  String zipCode

  @Editable
  String city

  @Editable
  String country

  @JsonIgnore
  var Racks racks

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
    racks = new Racks(pcls)
    racks.parent = this
  }

  override getIdent() {
    name ?: '' + hashCode
  }

}
