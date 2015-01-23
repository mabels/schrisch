package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Data

@Data
class Port {
	String name
	String label
	String type
	String remote_port
	String l2address
	String cable
	
}