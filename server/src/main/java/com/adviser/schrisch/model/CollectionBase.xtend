package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener
import java.beans.PropertyChangeSupport
import java.util.Collection
import java.util.HashSet

class CollectionBase<T extends Parentable, P> extends Base implements Valueable {

  val collection = new HashSet<T>()

  val _propertyChangeSupport = new PropertyChangeSupport(this)

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|_propertyChangeSupport.addPropertyChangeListener(pcl)]
  }

  def getPropertyChangeListeners() {
    _propertyChangeSupport.propertyChangeListeners
  }

  def getCollection() {
    return collection
  }

  def add(T type) {
    type.setParent(this)
    val _oldValue = collection.clone
    collection.add(type)
    _propertyChangeSupport.firePropertyChange("add", _oldValue, collection);
    return type
  }

  def remove(T type) {
    val _oldValue = collection.clone
    if (collection.remove(type)) {
      _propertyChangeSupport.firePropertyChange("remove", _oldValue, collection);
    }
    return type
  }

  override values() {
    collection
  }

  def Collection<T> valuesTyped() {
    collection
  }

}
