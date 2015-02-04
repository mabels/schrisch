package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

class Spaces extends CollectionBase<Space, Content> {

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    super(pcls)
  }

  override getIdent() {
    "spaces"
  }

}
