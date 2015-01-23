package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Content {
	String name 
	String label 
	String asset_no
	String type
	String tags 
	Iterable<Space> spaces
	Iterable<Port> ports
	Iterable<Ip> ips 
	boolean has_problems
	Map<String, String> attributes 
	String id 
	new(String name, String label, String asset_no, String type, String tags, 
		Iterable<Space> spaces, Iterable<Port> ports, Iterable<Ip> ips, boolean has_problems, Map<String, String> attributes, String id) {
		this.name = name
		this.label = label
		this.asset_no = asset_no
		this.type = type
		this.tags = tags
		this.spaces = spaces
		this.ports = ports
		this.ips = ips
		this.has_problems = has_problems
		this.attributes = attributes
		this.id = id
		
	}
	
	def getIdent() {
		Utils.clean_fname(
			if (name != null && !name.trim.empty) {
				name.trim
			} else {
				id	
			}
		)
	}
    
}