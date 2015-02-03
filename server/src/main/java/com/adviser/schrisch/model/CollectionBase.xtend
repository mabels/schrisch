package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener
import java.util.Collection
import java.util.HashSet
import java.beans.PropertyChangeSupport

class CollectionBase<T extends Parentable, P> extends Base implements Valueable {

  val collection = new HashSet<T>()

  val _propertyChangeSupport = new PropertyChangeSupport(this)

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|_propertyChangeSupport.addPropertyChangeListener(pcl)]
  }

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
