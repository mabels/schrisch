package com.adviser.schrisch.model

import java.util.HashSet
import java.util.Collection

class CollectionBase<T, P> extends Base<P> implements Valueable {
	
	new(P parent) {
		this.parent = parent
	}

	val collection = new HashSet<T>()

	def add(T type) {
		
		collection.add(type)
	}

	override values() {
		collection
	}
	def Collection<T> valuesTyped() {
		collection
	}
}