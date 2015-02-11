package com.adviser.schrisch

import com.adviser.schrisch.model.Parentable
import java.util.List

class Utils {

  def static clean_fname(String fname) {
    return fname.toLowerCase.replaceAll("[^a-z0-9]+", '-')
  }

  def static <C extends AutoCloseable> doTry(C closable, (C)=>void fn) {
    closable.transform [
      fn.apply(closable)
      return null
    ]
  }

  def static <C extends AutoCloseable, R> transform(C closable, (C)=>R fn) {
    if (closable !== null) {
      try {
        return fn.apply(closable)
      } finally {
        closable.close()
      }
    }
  }

  def static getRoot(Object in) {
    var Parentable item = null
    if (in instanceof Parentable) {
      item = in
      while (item.parent !== null) {
        val o = item.parent
        if (o instanceof Parentable) {
          item = o
        }
      }
    }
    return item
  }

  def static getTreePath(Object in) {
    val List<Object> list = newArrayList
    list += in
    if (in instanceof Parentable) {
      var item = in.parent
      while (item !== null) {
        list += item
        item = if (item instanceof Parentable) {
          item = item.parent
        }
      }
    }
    return list
  }

}
