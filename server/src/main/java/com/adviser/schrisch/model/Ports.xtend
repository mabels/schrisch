package com.adviser.schrisch.model

import java.beans.PropertyChangeListener

class Ports extends CollectionBase<Port, Content> {

  new(PropertyChangeListener[] pcls) {
    super(pcls)
  }

  override getIdent() {
    "ports"
  }

}
