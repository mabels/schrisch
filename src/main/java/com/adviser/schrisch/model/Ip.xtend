package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Ip extends Base {
	String version
	String type
	String ip
	String name
	String address
	
	static def create(String version, String type, String ip, String name, String address) {
		val my = new Ip()
		my.version = version
		my.type = type
		my.ip = ip
		my.name = name
		my.address = address
		return my
	}
}