package com.adviser.schrisch.model.dto

import com.adviser.schrisch.model.DataCenters
import com.fasterxml.jackson.databind.ObjectMapper
import java.io.File
import java.io.FileOutputStream
import java.util.LinkedList
import org.slf4j.LoggerFactory

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
//		yf.writer
//		.writeObject(object)
		fos.close
	}

	def static write(DataCenters dc) {
//		//val yf = new YAMLFactory()
//		val yf = new ObjectMapper(new YAMLFactory())
//		dc.racks.values.forEach [ rack |
//			val my_rack = rack.clone
//			my_rack.contents = null // Avoid the serialization of contents
//			writeYaml(yf, new Space('x', 'y'), rack.ident, '''«rack.ident».rack''')
//			rack.contents.values.forEach[content |
//				LOGGER.debug("ident="+content.ident)
//				writeYaml(yf, content, content.ident, rack.ident, '''«content.ident».rack''')
//			]
//		]
	}
}
