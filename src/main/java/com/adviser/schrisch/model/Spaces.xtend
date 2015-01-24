package com.adviser.schrisch.model

class Spaces extends CollectionBase<Space, Content> {

	new(Content parent) {
		super(parent)
	}

	override getIdent() {
		"spaces"
	}

}
