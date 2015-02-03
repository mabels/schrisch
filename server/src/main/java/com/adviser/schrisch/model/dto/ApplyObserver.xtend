package com.adviser.schrisch.model.dto

import com.adviser.schrisch.model.DataCenters
import java.beans.PropertyChangeListener

class Observer {
  static def add(DataCenters dataCenters, PropertyChangeListener pcl) {
    dataCenters.collection.forEach[dataCenter|
      dataCenter.addPropertyChangeListener(pcl)
      dataCenter.racks.collection.forEach[rack|
        rack.addPropertyChangeListener(pcl)
        rack.contents.collection.forEach[content|
          content.addPropertyChangeListener(pcl)
        ]
      ]
    ]
  }
}