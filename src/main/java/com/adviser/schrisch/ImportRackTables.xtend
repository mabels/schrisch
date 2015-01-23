package com.adviser.schrisch

import com.adviser.schrisch.model.dto.RackTablesApi
import com.adviser.schrisch.model.dto.SchrischFileApi
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import java.io.File
import org.eclipse.xtend.lib.annotations.Accessors

class ImportRackTables {
	@Accessors
	static class Config {
		String apiurl
	}

	val mapper = new ObjectMapper(new YAMLFactory());

	def niam(String[] args) {
		val config = mapper.readValue(new File("config.yaml"), Config)
		val api = new RackTablesApi(config)
		val dataCenter = api.loadFromRackTables()
		SchrischFileApi.write(dataCenter)
		
	}

	def static main(String[] args) {
		(new ImportRackTables()).niam(args)

	}
}
