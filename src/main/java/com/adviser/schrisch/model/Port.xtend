package com.adviser.schrisch.model

class Port extends Base<Ports> {
	String name
	String label
	String type
	String remote_port
	String l2address
	String cable
	
	new(String name, String label, String type, String remote_port, String l2address, String cable) {
		this.name = name
		this.label = label
		this.type = type
		this.remote_port = remote_port
		this.l2address = l2address
		this.cable = cable
	}

}
