package com.adviser.schrisch

import com.adviser.schrisch.model.DataCenters
import com.adviser.schrisch.model.dto.RackTablesApi
import com.adviser.schrisch.model.dto.SchrischFileApi
import java.beans.PropertyChangeSupport

class ImportRackTables {

  def static main(String[] args) {
    val dataCenters = loadDataCenters()
    SchrischFileApi.write(dataCenters)
  }

  def static loadDataCenters() {
  	return SchrischFileApi.read((new PropertyChangeSupport(new Object())).propertyChangeListeners)
  }
  
  def static apiLoadDataCenters() {
    val config = Config.load
    return RackTablesApi.loadFromRackTables(config, (new PropertyChangeSupport(config)).propertyChangeListeners)
  }
  
  def static saveDataCenters(DataCenters dataCenters) {
  	SchrischFileApi.write(dataCenters)
  }

}
