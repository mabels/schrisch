package com.adviser.schrisch.model

class Ips extends CollectionBase<Ip, Content> {
	
	new(Content parent) {
		super(parent)
	}
	override getIdent() {
		"ips"
	}
	
	
}