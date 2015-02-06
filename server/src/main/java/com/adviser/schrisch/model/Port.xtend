package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

@Observable
class Port extends Base {

  @Editable
  String name

  @Editable
  String label

  @Editable
  String type

  @Editable
  String remote_port

  @Editable
  String l2address

  @Editable
  String cable

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
  }

  static def create(PropertyChangeListener[] pcls, String name, String label, String type, String remote_port,
    String l2address, String cable) {
    val my = new Port(pcls)
    my.setName(name)
    my.setLabel(label)
    my.setType(type)
    my.setRemote_port(remote_port)
    my.setL2address(l2address)
    my.setCable(cable)
    return my
  }

}
