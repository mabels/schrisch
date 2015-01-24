package com.adviser.schrisch.model

class Ports extends CollectionBase<Port, Content> {

	new(Content parent) {
		super(parent)
	}

	override getIdent() {
		"ports"
	}

}
