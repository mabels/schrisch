package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonIgnore
import java.beans.PropertyChangeListener
import org.apache.commons.lang.math.Fraction
import java.util.Arrays

@Observable
class Content extends Base {

  @Editable
  String name

  @Editable
  String label

  @Editable
  String asset_no

  @Editable
  String type

  @Editable
  String tags

  @Editable
  boolean has_problems

  @Editable
  String id

  var Spaces spaces
  var Ports ports
  var Ips ips
  var Attributes attributes

  @JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
    spaces = new Spaces(pcls)
    spaces.parent = this
    ports = new Ports(pcls)
    ports.parent = this
    ips = new Ips(pcls)
    ips.parent = this
    attributes = new Attributes(pcls)
    attributes.parent = this
  }

  static def create(PropertyChangeListener[] pcls, String name, String label, String asset_no, String type,
    String tags, boolean has_problems, String id) {
    val ct = new Content(pcls)
    ct.setName(name)
    ct.setLabel(label)
    ct.setAsset_no(asset_no)
    ct.setType(type)
    ct.setTags(tags)
    ct.setHas_problems(has_problems)
    ct.setId(id)
    return ct
  }

  override getIdent() {
    Utils.clean_fname(label?.trim ?: name?.trim ?: id ?: super.ident)
  }

  @JsonIgnore
  def getBox() {

    //System.err.println("space=>begin");
    val sorted = spaces.valuesTyped.sortWith([ a, b |
        var cval = a.unit_no.compareTo(b.unit_no)
        if(cval == 0) {

          //luck lexical sorted ["front","middle", "rear"] 
          cval = a.atom.compareTo(b.atom)
        }
        cval
      ])
    if(sorted.length > 0) {
      val deepmap = #{"front" -> Fraction.ZERO, "mid" -> Fraction.ONE_THIRD, "rear" -> Fraction.TWO_THIRDS}
      val rowPrev = #{"mid" -> "front", "rear" -> "mid"}
      val box = new Box  
      sorted.forEach [ space |
        //System.err.println("space=>" + space.unit_no + ":" + space.atom)
        if(box.last == null) {
          box.startHeight = space.unit_no
          box.height = 1
          box.startDeep = deepmap.get(space.atom)
          box.deep = Fraction.ONE_THIRD
          box.startBox = space
          box.firstRowLast = space
        } else {
          if(space.unit_no.equals(box.last.unit_no)) {
            // same row
            if(!box.last.atom.equals(rowPrev.get(space.atom))) {
              throw new RuntimeException(
                "This space is not connected in the deep:" + box.last.atom + ":" + space.atom)
            }
            box.deep = box.deep.add(Fraction.ONE_THIRD)
            if (box.height == 1) {
              box.firstRowLast = space
            }
          } else {
            if(!box.last.unit_no.equals(space.unit_no - 1)) {
              throw new RuntimeException(
                "This space is not connected in the height:" + box.startBox.unit_no + ":" +
                  space.unit_no)
            }    
            if(!box.startBox.atom.equals(space.atom)) {
              throw new RuntimeException(
                "This space is not connected at the starting deep:" + box.startBox.atom + ":" +
                  space.atom)
            }
            box.height = box.height + 1
            box.deep = Fraction.ONE_THIRD
          } 
        }
        box.last = space
      ]
      if(!box.firstRowLast.atom.equals(box.last.atom)) {
        throw new RuntimeException(
          "The box is not closed:" + box.firstRowLast.atom + ":" + box.last.atom
        )
      }
      return box
    }
    return null
  }

}
