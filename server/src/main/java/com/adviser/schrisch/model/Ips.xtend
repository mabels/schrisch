package com.adviser.schrisch.model

import java.beans.PropertyChangeListener

class Ips extends CollectionBase<Ip, Content> {
  
  new(PropertyChangeListener[] pcls) {
    super(pcls)
  }

	override getIdent() {
		"ips"
	}
	
	
}