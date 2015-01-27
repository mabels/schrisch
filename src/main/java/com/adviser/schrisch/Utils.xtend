package com.adviser.schrisch

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
    if(closable !== null) {
      try {
        return fn.apply(closable)
      } finally {
        closable.close()
      }
    }
  }

}
