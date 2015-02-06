package com.adviser.schrisch.model

import com.fasterxml.jackson.annotation.JsonIgnore
import java.lang.reflect.Field

class Base implements Identable, Parentable, Elementable {
  @JsonIgnore
  var Object _parent = null

  @JsonIgnore
  override String getIdent() {
    "" + hashCode
  }

  override getParent() {
    return _parent
  }

  override void setParent(Object parent) {
    this._parent = parent
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

    new(Field field, Object o) {
      this.field = field
      this.o = o
    }

    def type() {
      field.type
    }

    def get() {
      val accessible = field.accessible
      try {
        field.accessible = true
        field.get(o)
      } finally {
        field.accessible = accessible
      }
    }

    def set(Object value) {
      val accessible = field.accessible
      try {
        field.accessible = true
        field.set(o, value)
      } finally {
        field.accessible = accessible
      }
    }

    override toString() {
      get()?.toString
    }

  }

}
