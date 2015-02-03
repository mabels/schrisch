package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable

@Observable
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