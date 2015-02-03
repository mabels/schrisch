package com.adviser.schrisch.model

import java.util.Collection
import java.util.HashSet

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
	
//	override void addPropertyChangeListener(PropertyChangeListener pcl) {
//	  collection.forEach[c|
//	    c.addPropertyChangeListener(pcl)
//	  ]
//	}
}
