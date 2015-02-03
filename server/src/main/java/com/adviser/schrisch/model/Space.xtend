package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

@Observable
class Space extends Base {
  String unit_no
  String atom

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
  }

  static def create(PropertyChangeListener[] pcls, String unit_no, String atom) {
    val my = new Space(pcls)
    my.setUnit_no(unit_no)
    my.setAtom(atom)
    return my
  }

}
