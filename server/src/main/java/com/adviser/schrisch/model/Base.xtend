package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JsonIgnore
import java.lang.reflect.Field
import java.lang.reflect.Method
import java.util.UUID

abstract class Base implements Identable, Parentable, Elementable, AddPropertyChangeListener {
  @JsonIgnore
  var Object _parent = null

  var String objectId = null
  
 
  def setObjectId(String _objectId) {
    objectId = _objectId
  }

  override getObjectId() {
    synchronized(this) {
      if(objectId == null) {
        objectId = UUID.randomUUID().toString
      }
    }
    objectId
  }

  @JsonIgnore
  override String getIdent() {
    "" + objectId
  }

  @JsonIgnore
  override getParent() {
    return _parent
  }

  override void setParent(Object parent) {
    this._parent = parent
  }
  
  override hashCode() {
    getObjectId().hashCode
  }
  
  override equals(Object obj) {
    if (this === obj) return true
    if (obj === null) return false
    if (class !== obj.class) return false
    val that = obj as Base
    return getObjectId() == that.getObjectId()
  }

  @JsonIgnore
  override getElements() {
    class.declaredFields.filter[isAnnotationPresent(Editable)].filter [ field |
      val orig = field.accessible
      try {
        field.accessible = true
        !(field.get(this) instanceof Valueable)
      } finally {
        field.accessible = orig
      }
    ].map [ field |
      val orig = field.accessible
      try {
        field.accessible = true
        return field.name -> new Base.ReflectedMutableObject(field, this)
      } finally {
        field.accessible = orig
      }
    ]
  }

  public static class ReflectedMutableObject {

    Field field

    Object o

    Method getter

    Method setter

    new(Field field, Object o) {
      this.field = field
      this.o = o
      this.getter = field.declaringClass.getMethod('''get«field.name.toFirstUpper»''')
      this.setter = field.declaringClass.getMethod('''set«field.name.toFirstUpper»''', field.type)
    }

    def type() {
      field.type
    }

    def get() {
      this.getter.invoke(o)
    }

    def set(Object value) {
      this.setter.invoke(o, value)
    }

    override toString() {
      get()?.toString
    }

  }

}
