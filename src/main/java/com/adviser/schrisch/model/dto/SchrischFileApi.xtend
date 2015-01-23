package com.adviser.schrisch.model.dto

import com.adviser.schrisch.model.DataCenter
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import java.util.LinkedList
import java.io.File
import org.slf4j.LoggerFactory

class SchrischFileApi {
	static val LOGGER = LoggerFactory.getLogger(SchrischFileApi)
	
	def static get_file(String ... name) {
		val my = new LinkedList<String>()
		my.push("./schrisch")
		my.addAll(name)
		val ret = new File(my.join('/'))
		my.removeLast()
		(new File(my.join('/'))).mkdirs()
		return ret
	}

	def static write(DataCenter dc) {
		val mapper = new ObjectMapper(new YAMLFactory());
		dc.racks.values.forEach [ rack |
			val my_rack = rack.clone
			my_rack.contents = null // Avoid the serialization of contents
			mapper.writeValue(get_file(rack.ident, '''«rack.ident».rack'''), my_rack) 
			rack.contents.values.forEach[content |
				LOGGER.debug("ident="+content.ident)
				mapper.writeValue(get_file(rack.ident, '''«content.ident».content'''), content) 
			]
		]
	}
}
