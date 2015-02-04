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
    val _oldValue = collection.clone
    collection.add(type)
     _propertyChangeSupport.firePropertyChange("add", _oldValue, collection);
    return type
  }

  def +=(T type) {
    add(type)
    collection
  }

//  def +=(Iterable<T> list) {
//    add(type)
//    collection
// 
//    collection += list
//  }

  override values() {
    collection
  }

  def Collection<T> valuesTyped() {
    collection
  }

}
