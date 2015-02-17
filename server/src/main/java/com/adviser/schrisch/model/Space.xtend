package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

@Observable
class Space extends Base {

  @Editable
  Integer unit_no

  @Editable
  String atom

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
  }
  
  new(Integer unit_no, String atom) {
    this.unit_no = unit_no
    this.atom = atom
  }

  static def create(PropertyChangeListener[] pcls, Integer unit_no, String atom) {
    val my = new Space(pcls)
    my.setUnit_no(unit_no)
    my.setAtom(atom)
    return my
  }

}
