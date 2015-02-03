package com.adviser.schrisch

import com.adviser.schrisch.model.dto.RackTablesApi
import com.adviser.schrisch.model.dto.SchrischFileApi
import com.adviser.schrisch.model.DataCenters

class ImportRackTables {

  def static main(String[] args) {
    val dataCenters = loadDataCenters()
    SchrischFileApi.write(dataCenters)
  }

  def static loadDataCenters() {
  	return SchrischFileApi.read()
  }
  
  def static apiLoadDataCenters() {
    val config = Config.load
    return RackTablesApi.loadFromRackTables(config)
  }
  
  def static saveDataCenters(DataCenters dataCenters) {
  	SchrischFileApi.write(dataCenters)
  }

}
