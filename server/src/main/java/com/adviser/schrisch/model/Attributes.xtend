package com.adviser.schrisch.model

import java.beans.PropertyChangeListener

class Attributes extends CollectionBase<Attribute, Content> {

  new(PropertyChangeListener[] pcls) {
    super(pcls)
  }
  
	override getIdent() {
		"attributes"
	}
	
}