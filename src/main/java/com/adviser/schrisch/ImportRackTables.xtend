package com.adviser.schrisch

import com.adviser.schrisch.model.dto.RackTablesApi
import com.adviser.schrisch.model.dto.SchrischFileApi

class ImportRackTables {

  def static main(String[] args) {
    val dataCenters = loadDataCenters()
    SchrischFileApi.write(dataCenters)
  }

  def static loadDataCenters() {
    val config = Config.load
    return RackTablesApi.loadFromRackTables(config)
  }
  
  def static saveDataCenters() {
  }

}
