package com.adviser.schrisch.model

import org.apache.commons.lang.math.Fraction
import org.eclipse.xtend.lib.annotations.Accessors

class Box {
  @Accessors
  Fraction start_width = Fraction.ZERO // absolute left
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
    start_width = sw
    width = w
    startHeight = sh
    height = h
    startDeep = sd
    deep = d
  }

  override equals(Object o) {
    val Box other = o as Box
    for (i : #[
      #[this.start_width, other.start_width],
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

  override toString() {
    return "<Box@" + hashCode + ":sw=" + start_width + ":w=" + width + ":sh=" + startHeight + ":h=" + height + ":sd=" +
      startDeep + ":d=" + deep + ">"

  }
}
