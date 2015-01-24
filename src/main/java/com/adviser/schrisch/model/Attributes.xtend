package com.adviser.schrisch.model

class Attributes extends CollectionBase<Attribute, Content> {
	
	new(Content parent) {
		super(parent)
	}
	
	override getIdent() {
		"attributes"
	}
}