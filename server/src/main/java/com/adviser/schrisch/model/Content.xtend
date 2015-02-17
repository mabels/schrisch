package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener
import org.eclipse.xtend.lib.annotations.Data
import java.util.Comparator
import java.util.LinkedList
import java.util.Arrays
import org.apache.commons.lang.math.Fraction

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

  static class Box {
    var Fraction start_width = Fraction.ZERO // absolute left
    var Fraction width = Fraction.ONE // width is 100%
    var int startHeight // in U's
    var int height // in U's
    var Fraction startDeep
    var Fraction deep
    var Space last = null
    var Space startBox = null
    var Space firstRowLast = null

    new() {
    }

    new(Fraction sw, Fraction w, int sh, int h, Fraction sd, Fraction d) {
      start_width = sw
      width = w
      startHeight = sh
      height = h
      startDeep = sd
      deep = d
    }

    override equals(Object o) {
      val Box other = o as Box
      for (i : #[
        #[this.start_width, other.start_width],
        #[this.width, other.width],
        #[this.startHeight, other.startHeight],
        #[this.height, other.height],
        #[this.startDeep, other.startDeep],
        #[this.deep, other.deep]
      ]) {
        val ret = i.get(0).equals(i.get(1))
        if(!ret) {
          return false
        }
      }
      return true
    }

    override toString() {
      return "<Box@"+hashCode+":sw="+start_width+":w="+width+":sh="+startHeight+":h="+height+":sd="+startDeep+":d="+deep+">"
      
    }
  }

  def getBoxes() {

    //System.err.println("space=>begin");
    val ret = new LinkedList<Box>()
    val sorted = spaces.collection.sortWith(
      [ a, b |
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
      ret.push(new Box()) // currently we can only sum up one box
      sorted.forEach [ space |
        val box = ret.last
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
            box.height += 1
            box.deep = Fraction.ONE_THIRD
          } 
        }
        box.last = space
      ]
      if(!ret.last.firstRowLast.atom.equals(ret.last.last.atom)) {
        throw new RuntimeException(
          "The box is not closed:" + ret.last.firstRowLast.atom + ":" + ret.last.last.atom
        )
      }
    }
    ret.toArray(newArrayOfSize(ret.length))
  }

}
