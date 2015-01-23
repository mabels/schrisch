package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.HashMap

@Accessors
class Rack implements Cloneable {
	public override Rack clone() {
		super.clone as Rack
	}
	String name
	int height
	String comment
	String row
	Map<String, Content> contents
	
	new(String name, int height, String comment, String row, HashMap<String, Content> contents) {
		this.name = name
		this.height = height
		this.comment = comment
		this.row = row
		this.contents = contents
	}
	
	
	def getIdent() {
      Utils.clean_fname(row+"-"+name)
    }
}