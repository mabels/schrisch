package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

class Ports extends CollectionBase<Port> {

  @JsonCreator
  new(@JacksonInject("pcls")PropertyChangeListener[] pcls) {
    super(pcls)
  }

  override add(Port type) {
    super.add(type)
  }

  override getIdent() {
    "ports"
  }

}
