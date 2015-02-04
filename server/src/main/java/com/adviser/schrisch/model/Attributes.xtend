package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

class Attributes extends CollectionBase<Attribute, Content> {

  @JsonCreator
  new(@JacksonInject("pcls")PropertyChangeListener[] pcls) {
    super(pcls)
  }
  
	override getIdent() {
		"attributes"
	}
	
}