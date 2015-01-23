package com.adviser.schrisch.model

import java.util.Map
import org.eclipse.xtend.lib.annotations.Data

@Data
class DataCenter {
	Map<String, Rack> racks
	
	
}