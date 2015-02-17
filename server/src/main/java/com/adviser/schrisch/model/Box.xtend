package com.adviser.schrisch.model

import org.apache.commons.lang.math.Fraction
import org.eclipse.xtend.lib.annotations.Accessors

class Box {
  @Accessors
  Fraction startWidth = Fraction.ZERO // absolute left
  @Accessors
  Fraction width = Fraction.ONE // width is 100%
  @Accessors
  int startHeight // in U's
  @Accessors
  int height // in U's
  @Accessors
  Fraction startDeep
  @Accessors
  Fraction deep
  @Accessors
  Space last = null
  @Accessors
  Space startBox = null
  @Accessors
  Space firstRowLast = null

  new() {
  }

  new(Fraction sw, Fraction w, int sh, int h, Fraction sd, Fraction d) {
    startWidth = sw
    width = w
    startHeight = sh
    height = h
    startDeep = sd
    deep = d
  }

  override equals(Object o) {
    val Box other = o as Box
    for (i : #[
      #[this.startWidth, other.startWidth],
      #[this.width, other.width],
      #[this.startHeight, other.startHeight],
      #[this.height, other.height],
      #[this.startDeep, other.startDeep],
      #[this.deep, other.deep]
    ]) {
      val ret = i.get(0).equals(i.get(1))
      if(!ret) {
        return false
      }
    }
    return true
  }

  static class BoxAsDouble {
    @Accessors
    val double startWidth
    @Accessors
    val double width
    @Accessors
    val double startHeight 
    @Accessors
    val double height
    @Accessors
    val double startDeep
    @Accessors
    val double deep

    new(Box box) {
      startWidth = box.startWidth.doubleValue
      width = box.width.doubleValue
      startHeight = box.startHeight.doubleValue
      height = box.height
      startDeep = box.startDeep.doubleValue
      deep = box.deep.doubleValue
    }
  }

  override toString() {
    return "<Box@" + hashCode + ":sw=" + startWidth + ":w=" + width + ":sh=" + startHeight + ":h=" + height +
      ":sd=" + startDeep + ":d=" + deep + ">"

  }
}
