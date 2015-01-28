package com.adviser.schrisch.model

import java.util.HashSet
import java.util.Collection

class CollectionBase<T extends Parentable, P> extends Base implements Valueable {

	val collection = new HashSet<T>()

	def getCollection() {
		return collection
	}

	def add(T type) {
		type.setParent(parent)
		collection.add(type)
		return type
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
