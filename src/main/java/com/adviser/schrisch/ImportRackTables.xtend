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

  def static main(String[] args) {
    val dataCenter = loadDataCenter()
    SchrischFileApi.write(dataCenter)

  }

  def static loadDataCenter() {
    val mapper = new ObjectMapper(new YAMLFactory());
    val ImportRackTables.Config config = mapper.readValue(new File("config.yaml"), Config)
    return RackTablesApi.loadFromRackTables(config)
  }

}
