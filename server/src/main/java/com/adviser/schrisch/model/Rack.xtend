package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonIgnore
import java.beans.PropertyChangeListener

@Observable
class Rack extends Base implements Cloneable {

  @Editable
  String name

  @Editable
  String height

  @Editable
  String comment

  @Editable
  String row

  @JsonIgnore
  val Contents contents

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
    contents = new Contents(pcls)
    contents.parent = this
  }

  static def create(PropertyChangeListener[] pcls, String name, int height, String comment, String row) {
    val my = new Rack(pcls)
    my.setName(name)
    my.setHeight("" + height)
    my.setComment(comment)
    my.setRow(row)
    return my
  }

  public override Rack clone() {
    super.clone as Rack
  }

  override getIdent() {
    Utils.clean_fname(row + "-" + name)
  }

}
