package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Attribute extends Base {
	String label
	String value
	
	static def create(String label, String value) {
	  val my = new Attribute()
		my.label = label
		my.value = value
		return my
	}
	
	override getIdent() {
		label
	}
	
}