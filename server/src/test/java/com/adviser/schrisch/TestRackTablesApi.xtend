package com.adviser.schrisch

import com.adviser.schrisch.model.dto.RackTablesApi
import com.google.common.io.Files
import java.io.File
import org.junit.Test

import static org.junit.Assert.*

class TestRackTablesApi {


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

    val dcs = rta.load_datacenters(newArrayOfSize(0))
    dcs.valuesTyped.forEach [ dc |
      dc.racks.valuesTyped.forEach [ rack |
        assertEquals("B.1", rack.name)
        assertEquals(42, rack.height)
        rack.contents.valuesTyped.forEach [ content |
          if("B1 C4".equals(content.name)) {
            assertNull(content.label)
            assertNull(content.asset_no)
            assertEquals("CableOrganizer", content.type)
            assertEquals(1, content.spaces.values.length)
            assertEquals(27, content.spaces.valuesTyped.findFirst[true].unit_no)
            assertEquals("front", content.spaces.valuesTyped.findFirst[true].atom)
          }
        ]
      ]
    ]
  }
}
