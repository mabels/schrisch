package com.adviser.schrisch

import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import java.io.File

@Accessors
class Config {
	String apiurl
	String organisation

	def static load() {
		val mapper = new ObjectMapper(new YAMLFactory());
		mapper.readValue(new File("config.yaml"), Config)
	}
}
