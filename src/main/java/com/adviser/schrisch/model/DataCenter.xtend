package com.adviser.schrisch.model

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.HashMap

@Accessors
class DataCenter {
	val Map<String, Rack> racks
	
	new(HashMap<String, Rack> map) {
		racks = map
	}
	
	
}