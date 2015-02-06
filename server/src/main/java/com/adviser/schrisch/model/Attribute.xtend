package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

@Observable
class Attribute extends Base {

  @Editable
  String label

  @Editable
  String value

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
  }

  static def create(PropertyChangeListener[] pcls, String label, String value) {
    val my = new Attribute(pcls)
    my.setLabel(label)
    my.setValue(value)
    return my
  }

  override getIdent() {
    label ?: '' + hashCode
  }

}
