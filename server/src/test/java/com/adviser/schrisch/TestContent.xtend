package com.adviser.schrisch

import com.adviser.schrisch.model.Box
import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.Space
import org.apache.commons.lang.math.Fraction
import org.junit.Test
import static org.junit.Assert.*

class TestContent {
 
  def createSpaces(Space[] spaces) {
    val c = new Content(newArrayOfSize(0))
    spaces.forEach [ space |
      c.spaces.add(space)
    ]
    c.box
  }
  
 
  @Test def testBoxesEmpty() {
    assertNull(createSpaces(#[]))
  }

  @Test def testBoxesSimpleFront() {
    assertEquals(new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.ZERO, Fraction.ONE_THIRD), createSpaces(#[new Space(4, "front")]))
  }

  @Test def testBoxesSimpleMid() {
    assertEquals(new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.ONE_THIRD, Fraction.ONE_THIRD), createSpaces(#[new Space(4, "mid")]))
  }

  @Test def testBoxesSimpleRear() {
    assertEquals(new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.TWO_THIRDS, Fraction.ONE_THIRD), createSpaces(#[new Space(4, "rear")]))
  }

  @Test def testBoxesFullLength() {
    assertEquals(new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.ZERO, Fraction.ONE),
      createSpaces(#[new Space(4, "front"), new Space(4, "mid"), new Space(4, "rear")]))
  }

  @Test def testBoxesFrontDoubleHeight() {
    assertEquals(new Box(Fraction.ZERO, Fraction.ONE, 4, 2, Fraction.ZERO, Fraction.ONE_THIRD),
      createSpaces(#[new Space(4, "front"), new Space(5, "front")]))
  }

  @Test def testBoxesFrontMidDoubleHeight() {
    assertEquals(new Box(Fraction.ZERO, Fraction.ONE, 4, 2, Fraction.ZERO, Fraction.TWO_THIRDS),
      createSpaces(#[new Space(4, "front"), new Space(5, "front"), new Space(4, "mid"), new Space(5, "mid")]))
  }

  @Test(expected = RuntimeException)
  def void testIllegalGeoMetrie_1() {
    createSpaces(#[new Space(4, "front"), new Space(4, "rear")])
  }

  @Test(expected = RuntimeException)
  def void testIllegalGeoMetrie_2() {
    createSpaces(#[new Space(4, "front"), new Space(5, "mid")])
  }
  
}