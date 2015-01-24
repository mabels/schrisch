package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Attribute extends Base<Attributes> {
	String label
	String value
	
	new(String label, String value) {
		this.label = label
		this.value = value
	}
	
	override getIdent() {
		label
	}
	
}