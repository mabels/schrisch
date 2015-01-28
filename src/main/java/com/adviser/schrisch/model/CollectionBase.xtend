package com.adviser.schrisch.model

import java.util.HashSet
import java.util.Collection

class CollectionBase<T, P> extends Base<P> implements Valueable {

	new(P parent) {
		this.parent = parent
	}

	val collection = new HashSet<T>()

	def getCollection() {
		return collection
	}

	def add(T type) {

		collection.add(type)
	}

	def +=(T type) {
		collection += type
	}

	def +=(Iterable<T> list) {
		collection += list
	}

	override values() {
		collection
	}

	def Collection<T> valuesTyped() {
		collection
	}
}
