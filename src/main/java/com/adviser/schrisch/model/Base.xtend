package com.adviser.schrisch.model

class Base<T> implements Identable, Parentable {
	var T parent = null
	
	def void setParent(T parent) {
		this.parent = parent
	}
	override String getIdent() {
		""+hashCode
	}
	
	override getParent() {
		return parent
	}
	
}