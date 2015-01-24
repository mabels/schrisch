package com.adviser.schrisch.model.dto

import com.adviser.schrisch.model.DataCenters
import com.fasterxml.jackson.databind.ObjectMapper
import java.io.File
import java.io.FileOutputStream
import java.util.LinkedList
import org.slf4j.LoggerFactory
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory

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
			writeYaml(yf, dc, dc.ident, dc.ident, '''«dc.ident».datacenter''')
			dc.racks.valuesTyped.forEach [ rack |
				writeYaml(yf, rack, dc.ident, rack.ident, '''«rack.ident».rack''')
				rack.contents.valuesTyped.forEach [ content |
					LOGGER.debug("ident=" + content.ident)
					writeYaml(yf, content, content.ident, dc.ident, rack.ident, '''«content.ident».rack''')
				]
			]
		]
	}
	
}
