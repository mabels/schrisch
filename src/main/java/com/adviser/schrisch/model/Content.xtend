package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import java.util.Map
import org.eclipse.xtend.lib.annotations.Data

@Data
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
	
	def getIdent() {
		Utils.clean_fname(
			if (name != null && !name.trim.empty) {
				name
			} else {
				id	
			}
		)
	}
    
}