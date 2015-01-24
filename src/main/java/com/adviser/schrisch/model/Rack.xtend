package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Rack extends Base<DataCenter> implements Cloneable {
  String name
  String height
  String comment
  String row

  val contents = new Contents(this)

  new(String name, int height, String comment, String row) {
    this.name = name
    this.height = "" + height
    this.comment = comment
    this.row = row
  }

  public override Rack clone() {
    super.clone as Rack
  }

  override getIdent() {
    Utils.clean_fname(row + "-" + name)
  }
}
