package com.adviser.schrisch.model

import java.util.LinkedList

class Base<T> implements Identable, Parentable, Elementable {
	var T parent = null

	def void setParent(T parent) {
		this.parent = parent
	}

	override String getIdent() {
		"" + hashCode
	}

	override getParent() {
		return parent
	}

	override getElements() {
		val ret = new LinkedList<Pair<String, Object>>()
		this.class.declaredFields.forEach [ field |
			val orig = field.accessible
			field.accessible = true
			val value = field.get(this)
			if(!(value instanceof Valueable)) {
				ret.add(field.name -> value)
			}
			field.accessible = orig
		]
		return ret
	}

}
