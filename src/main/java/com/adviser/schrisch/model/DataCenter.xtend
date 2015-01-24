package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class DataCenter extends Base<DataCenters> {
  String name
  String street
  String zipCode
  String city
  String country
  val racks = new Racks(this)

  override getIdent() {
    if(name != null) {
      name
    } else {
      name = "" + hashCode
    }
  }
}
