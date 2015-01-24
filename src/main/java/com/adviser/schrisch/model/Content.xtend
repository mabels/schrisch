package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Content extends Base<Contents> {
	String name 
	String label 
	String asset_no
	String type
	String tags 
	boolean has_problems
	String id 

	val spaces = new Spaces(this)
	val ports = new Ports(this)
	val ips  = new Ips(this)
	val attributes = new Attributes(this)
	
	new(String name, String label, String asset_no, String type, String tags, boolean has_problems, String id) {
		this.name = name
		this.label = label
		this.asset_no = asset_no
		this.type = type
		this.tags = tags
		this.has_problems = has_problems
		this.id = id		
	}
	
	override getIdent() {
		Utils.clean_fname(
			if (name != null && !name.trim.empty) {
				name.trim
			} else {
				id	
			}
		)
	}
    
}