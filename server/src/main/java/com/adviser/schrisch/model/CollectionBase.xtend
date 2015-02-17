package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonIgnore
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.beans.PropertyChangeSupport
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.TreeMap

class CollectionBase<T extends Parentable & AddPropertyChangeListener & Identable> extends Base implements Valueable {

  val ordered = new TreeMap<String, T>()
  val backRef = new HashMap<T, String>()

  @JsonIgnore
  val _propertyChangeSupport = new PropertyChangeSupport(this)

  val PropertyChangeListener identObserver

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|_propertyChangeSupport.addPropertyChangeListener(pcl)]

    identObserver = new PropertyChangeListener() {

      override propertyChange(PropertyChangeEvent evt) {
        if(!evt.propertyName.equals("ident")) {
          val ident = (evt.source as Identable).ident
          val t = ordered.get(ident)
          if(t != null) {
            return // found the ident in map
          }
          ordered.remove(backRef.remove(t))
          backRef.put(evt.source as T, ident)
          ordered.put(ident, evt.source as T)
        }
      }
    }
  }

  @JsonIgnore
  def getPropertyChangeListeners() {
    _propertyChangeSupport.propertyChangeListeners
  }

//  def getCollection() {
//    return collection
//  }

  def add(T type) {
    type.setParent(this)
    val _oldValue = backRef.values.clone
    backRef.put(type, type.ident)
    ordered.put(type.ident, type)
    type.addPropertyChangeListener(identObserver)
    _propertyChangeSupport.firePropertyChange("add", _oldValue, backRef.values);
    return type
  }

  def remove(T type) {
    val _oldValue = backRef.values.clone
    val t = backRef.remove(type)
    if(t != 0) {
      ordered.remove(t)
      _propertyChangeSupport.firePropertyChange("remove", _oldValue, backRef.values);
    }
    return type
  }

  override Collection<?> values() {
    valuesTyped()
  }

  def Collection<T> valuesTyped() {
    val ret = new ArrayList(ordered.size)
    for (i : ordered.entrySet) {
      ret.add(i.value)
    }
    ret
  }

  override addPropertyChangeListener(PropertyChangeListener pcl) {
    _propertyChangeSupport.addPropertyChangeListener(pcl)
  }

  override getPropertyChangeSupport() {
    return _propertyChangeSupport
  }

}
