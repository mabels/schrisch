package com.adviser.schrisch.model.dto

import com.adviser.schrisch.model.DataCenters
import com.fasterxml.jackson.databind.ObjectMapper
import java.io.File
import java.io.FileOutputStream
import java.util.LinkedList
import org.slf4j.LoggerFactory
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import java.io.FileFilter
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.Rack
import com.adviser.schrisch.model.Content

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
					LOGGER.debug("ident=" + content.ident)
					writeYaml(yf, content, dc.ident, rack.ident, '''«content.ident».content''')
				]
			]
		]
	}

	def static readRack(ObjectMapper yf, File rackDir) {
		val rackFiles = rackDir.listFiles(
			new FileFilter() {
				override accept(File pathname) {
					val ret = pathname.file && pathname.absolutePath.endsWith(".rack")
					if (ret) {
						 LOGGER.debug("pathname => "+pathname)
				    }
					ret
				}

			})
		if (rackFiles.size != 1) {
			LOGGER.error("can't read directory structure missing or to much .rack:" + rackDir.absolutePath);
			return null
		}
		val rack = yf.readValue(rackFiles.get(0), Rack)
		rackDir.listFiles(
			new FileFilter() {
				override accept(File pathname) {
					pathname.file && pathname.absolutePath.endsWith(".content")
				}

			}).forEach[ contentFile |
				rack.contents.add(yf.readValue(contentFile, Content))
			]
		return rack
	}
	
	def static readDataCenter(ObjectMapper yf, File dataCenterDir) {
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
		
		val dataCenter = yf.readValue(files.get(0), DataCenter)
		dataCenterDir.listFiles(new FileFilter() {
			
			override accept(File pathname) {
				pathname.isDirectory
			}
			
		}).forEach[ rackDir |
			val rack = readRack(yf, rackDir)
			if (rack != null) {
				dataCenter.racks.add(rack)
			}
		]
		dataCenter
	}

	def static read() {
		val yf = new ObjectMapper(new YAMLFactory())
		val dataCenters = new DataCenters()
		val root = new File("./schrisch")
		if (root.exists) {
			dataCenters += root.listFiles[it.isDirectory].map[file | readDataCenter(yf, file)].filterNull
		}
		return dataCenters
	}

}
