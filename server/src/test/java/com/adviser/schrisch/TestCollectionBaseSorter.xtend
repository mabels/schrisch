package com.adviser.schrisch

import com.adviser.xtend.annotation.Observable
import com.adviser.schrisch.model.Base
import com.adviser.schrisch.model.Editable
import org.junit.Test

import static org.junit.Assert.*
import com.adviser.schrisch.model.CollectionBase

class TestCollectionBaseSorter {
  @Observable
  static class UglyIdent extends Base {

    @Editable
    String inIdent

    @Editable
    String noIdent

    override getIdent() {
      "--" + inIdent?.toLowerCase + "--"
    }

    override toString() {
      "<UglyIdent@"+hashCode+":"+ident+">"
    }
  }

  @Test def testEmptyCollection() {
    assertArrayEquals(#[], (new CollectionBase<UglyIdent>(newArrayOfSize(0))).values)
  }

  @Test def testOneInOneOutCollection() {
    val cb = new CollectionBase<UglyIdent>(newArrayOfSize(0))
    val ui = new UglyIdent()
    cb.add(ui)
    assertArrayEquals(#[ui], cb.values)
    cb.remove(ui)
    assertArrayEquals(#[], cb.values)
  }

  @Test def testOneInChangeOneOutCollection() {
    val cb = new CollectionBase<UglyIdent>(newArrayOfSize(0))
    val ui = new UglyIdent()
    cb.add(ui)
    ui.noIdent = ""
    ui.inIdent = "TEST"
    assertArrayEquals(#[ui], cb.values)
    cb.remove(ui)
    assertArrayEquals(#[], cb.values)
  }

  @Test def testTwoPreAddedOrder() {
    val cb = new CollectionBase<UglyIdent>(newArrayOfSize(0))
    val b_ui = new UglyIdent()
    b_ui.noIdent = "b_ui"
    b_ui.inIdent = "Bui"
    cb.add(b_ui)
    val a_ui = new UglyIdent()
    a_ui.noIdent = "a_ui"
    a_ui.inIdent = "Aui"
    cb.add(a_ui)
    assertArrayEquals(#[a_ui, b_ui], cb.values)
    cb.remove(b_ui)
    assertArrayEquals(#[a_ui], cb.values)
    cb.remove(a_ui)
    assertArrayEquals(#[], cb.values)
  }

  @Test def testTwoPreAddedWithPostSwapOrder() {
    val cb = new CollectionBase<UglyIdent>(newArrayOfSize(0))
    val b_ui = new UglyIdent()
    b_ui.noIdent = "b_ui"
    b_ui.inIdent = "Bui"
    cb.add(b_ui)
    val a_ui = new UglyIdent()
    a_ui.noIdent = "a_ui"
    a_ui.inIdent = "Aui"
    cb.add(a_ui)
    assertArrayEquals(#[a_ui, b_ui], cb.values)
    a_ui.setInIdent("Xui")
    assertArrayEquals(#[b_ui, a_ui], cb.values)
    b_ui.setInIdent("Yui")
    assertArrayEquals(#[a_ui, b_ui], cb.values)
 
    cb.remove(b_ui)
    assertArrayEquals(#[a_ui], cb.values)
    cb.remove(a_ui)
    assertArrayEquals(#[], cb.values)
  }


}
