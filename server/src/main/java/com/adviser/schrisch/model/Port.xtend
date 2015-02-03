package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable

@Observable
class Port extends Base {
	String name
	String label
	String type
	String remote_port
	String l2address
	String cable
	
	static def create(String name, String label, String type, String remote_port, String l2address, String cable) {
		val my = new Port()
		my.name = name
		my.label = label
		my.type = type
		my.remote_port = remote_port
		my.l2address = l2address
		my.cable = cable
		return my
	}

}
