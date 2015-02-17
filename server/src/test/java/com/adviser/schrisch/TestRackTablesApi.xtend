package com.adviser.schrisch

import com.adviser.schrisch.model.dto.RackTablesApi
import com.google.common.io.Files
import java.beans.PropertyChangeSupport
import java.io.File
import org.junit.Test
import static org.junit.Assert.*
import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.Space
import org.apache.commons.lang.math.Fraction
import com.adviser.schrisch.model.Box

class TestRackTablesApi {

  val pcs = new PropertyChangeSupport(this)
  val pcl = pcs.getPropertyChangeListeners("test")

  def createSpaces(Space[] spaces) {
    val c = new Content(pcl)
    spaces.forEach [ space |
      c.spaces.add(space)
    ]
    c.boxes
  }
  
 
  @Test def testBoxesEmpty() {
    assertArrayEquals(#[], createSpaces(#[]))
  }

  @Test def testBoxesSimpleFront() {
    assertArrayEquals(#[new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.ZERO, Fraction.ONE_THIRD)], createSpaces(#[new Space(4, "front")]))
  }

  @Test def testBoxesSimpleMid() {
    assertArrayEquals(#[new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.ONE_THIRD, Fraction.ONE_THIRD)], createSpaces(#[new Space(4, "mid")]))
  }

  @Test def testBoxesSimpleRear() {
    assertArrayEquals(#[new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.TWO_THIRDS, Fraction.ONE_THIRD)], createSpaces(#[new Space(4, "rear")]))
  }

  @Test def testBoxesFullLength() {
    assertArrayEquals(#[new Box(Fraction.ZERO, Fraction.ONE, 4, 1, Fraction.ZERO, Fraction.ONE)],
      createSpaces(#[new Space(4, "front"), new Space(4, "mid"), new Space(4, "rear")]))
  }

  @Test def testBoxesFrontDoubleHeight() {
    assertArrayEquals(#[new Box(Fraction.ZERO, Fraction.ONE, 4, 2, Fraction.ZERO, Fraction.ONE_THIRD)],
      createSpaces(#[new Space(4, "front"), new Space(5, "front")]))
  }

  @Test def testBoxesFrontMidDoubleHeight() {
    assertArrayEquals(#[new Box(Fraction.ZERO, Fraction.ONE, 4, 2, Fraction.ZERO, Fraction.TWO_THIRDS)],
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

  @Test def testReadFromApi() {

    val config = new Config
    val rta = new RackTablesApi(config,
      new RackTablesApi.Request() {

        override request(String url) {
          if("/rack".equals(url)) {
            return Files.toByteArray(new File("src/test/resources/racks.json"))
          } else if("/object?rack=137".equals(url)) {
            return Files.toByteArray(new File("src/test/resources/object_137.json"))
          }
          return null
        }

      })

    val dcs = rta.load_datacenters(pcl)
    dcs.collection.forEach [ dc |
      dc.racks.collection.forEach [ rack |
        assertEquals("B.1", rack.name)
        assertEquals(42, rack.height)
        rack.contents.collection.forEach [ content |
          if("B1 C4".equals(content.name)) {
            assertNull(content.label)
            assertNull(content.asset_no)
            assertEquals("CableOrganizer", content.type)
            assertEquals(1, content.spaces.collection.length)
            assertEquals(27, content.spaces.collection.findFirst[true].unit_no)
            assertEquals("front", content.spaces.collection.findFirst[true].atom)
          }
        ]
      ]
    ]
  }
}
