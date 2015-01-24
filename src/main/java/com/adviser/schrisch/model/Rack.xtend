package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.HashMap

@Accessors
class Rack extends Base<DataCenter> implements Cloneable {
	public override Rack clone() {
		super.clone as Rack
	}
	String name
	String height
	String comment
	String row
	
	val contents = new Contents(this)
	
	new(String name, int height, String comment, String row) {
		this.name = name
		this.height = ""+height
		this.comment = comment
		this.row = row
	}
	
	override getIdent() {
      Utils.clean_fname(row+"-"+name)
    }
}