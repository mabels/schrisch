package com.adviser.schrisch.model.dto

import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.DataCenters
import com.adviser.schrisch.model.Rack
import com.fasterxml.jackson.databind.InjectableValues
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import java.beans.PropertyChangeListener
import java.io.File
import java.io.FileFilter
import java.io.FileOutputStream
import java.util.LinkedList
import org.slf4j.LoggerFactory

import static com.adviser.schrisch.model.dto.SchrischFileApi.*

class SchrischFileApi {
  static val LOGGER = LoggerFactory.getLogger(SchrischFileApi)

  def static writeYaml(ObjectMapper yf, Object object, String ... name) {
    val my = new LinkedList<String>()
    my.push("./schrisch")
    my.addAll(name)
    val ret = new File(my.join('/'))
    my.removeLast()
    (new File(my.join('/'))).mkdirs()
    val fos = new FileOutputStream(ret)
    yf.writeValue(fos, object)
    fos.close
  }

  def static write(DataCenters dcs) {
    val yf = new ObjectMapper(new YAMLFactory())
    dcs.valuesTyped.forEach [ dc |
      writeYaml(yf, dc, dc.ident, '''«dc.ident».datacenter''')
      dc.racks.valuesTyped.forEach [ rack |
        writeYaml(yf, rack, dc.ident, rack.ident, '''«rack.ident».rack''')
        rack.contents.valuesTyped.forEach [ content |
          //LOGGER.debug("ident=" + content.ident)
          writeYaml(yf, content, dc.ident, rack.ident, '''«content.ident».content''')
        ]
      ]
    ]
  }

  def static readRack(ObjectMapper yf, InjectableValues inject, File rackDir) {
    val rackFiles = rackDir.listFiles(
      new FileFilter() {
        override accept(File pathname) {
          val ret = pathname.file && pathname.absolutePath.endsWith(".rack")
          if(ret) {
            LOGGER.debug("pathname => " + pathname)
          }
          ret
        }

      })
    if(rackFiles.size != 1) {
      LOGGER.error("can't read directory structure missing or to much .rack:" + rackDir.absolutePath);
      return null
    }
    val Rack rack = yf.reader(Rack).with(inject).readValue(rackFiles.get(0))
    rackDir.listFiles(
      new FileFilter() {
        override accept(File pathname) {
          pathname.file && pathname.absolutePath.endsWith(".content")
        }
      }).forEach [ contentFile |
      rack.contents.add(yf.reader(Content).with(inject).readValue(contentFile))
    ]
    return rack
  }

  def static readDataCenter(ObjectMapper yf, InjectableValues inject, File dataCenterDir, DataCenters parent) {
    val files = dataCenterDir.listFiles(
      new FileFilter() {
        override accept(File pathname) {
          pathname.file && pathname.absolutePath.endsWith(".datacenter")
        }

      })
    if(files.size != 1) {
      LOGGER.error("can't read directory structure missing or to much .datacenter:" + dataCenterDir.absolutePath);
      return null
    }
    val DataCenter dataCenter = yf.reader(DataCenter).with(inject).readValue(files.get(0))
    dataCenter.parent = parent
    dataCenterDir.listFiles(
      new FileFilter() {

        override accept(File pathname) {
          pathname.isDirectory
        }

      }).forEach [ rackDir |
      val rack = readRack(yf, inject, rackDir)
      if(rack != null) {
        dataCenter.racks.add(rack)
      }
    ]
    dataCenter
  }

  def static read(PropertyChangeListener[] pcls) {
    val yf = new ObjectMapper(new YAMLFactory())
    val inject = new InjectableValues.Std().addValue("pcls", pcls)
//    yf.reader(Rack).with(inject)
//    yf.reader(DataCenter).with(inject)
    val dataCenters = new DataCenters(pcls)
    val root = new File("./schrisch")
    if(root.exists) {
      root.listFiles(
        new FileFilter() {
          override accept(File pathname) {
            pathname.isDirectory
          }
        }).forEach [ file |
        LOGGER.debug("DC=>" + file)
        dataCenters.add(readDataCenter(yf, inject, file, dataCenters))
      ]
    }
    return dataCenters
  }

}
