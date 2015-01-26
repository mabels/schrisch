package com.adviser.schrisch.model

import java.lang.reflect.Field
import java.util.LinkedList
import com.fasterxml.jackson.annotation.JsonIgnore

class Base<T> implements Identable, Parentable, Elementable {
  @JsonIgnore
  var T parent = null

  def void setParent(T parent) {
    this.parent = parent
  }

  @JsonIgnore
  override String getIdent() {
    "" + hashCode
  }

  override getParent() {
    return parent
  }

  @JsonIgnore
  override getElements() {
    new LinkedList<Pair<String, Object>>() => [ list |
      class.declaredFields.forEach [ field |
        val orig = field.accessible
        try {
          field.accessible = true
          if(!(field.get(this) instanceof Valueable)) {
            list.add(field.name -> new Base.ReflectedMutableObject(field, this))
          }
        } finally {
          field.accessible = orig
        }
      ]
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
