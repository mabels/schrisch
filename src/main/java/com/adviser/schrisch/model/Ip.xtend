package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Ip {
	String version
	String type
	String ip
	String name
	String address
	
	new(String version, String type, String ip, String name, String address) {
		this.version = version
		this.type = type
		this.ip = ip
		this.name = name
		this.address = address
	}
}