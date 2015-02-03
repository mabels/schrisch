package com.adviser.schrisch.model

import java.beans.PropertyChangeListener

class Spaces extends CollectionBase<Space, Content> {

  new(PropertyChangeListener[] pcls) {
    super(pcls)
  }

  override getIdent() {
    "spaces"
  }

}
