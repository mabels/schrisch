package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

@Observable
class Ip extends Base {
	String version
	String type
	String ip
	String name
	String address
	
	@JsonCreator
  new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
    pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
  }
  
	static def create(PropertyChangeListener[] pcls, String version, String type, String ip, String name, String address) {
		val my = new Ip(pcls)
		my.setVersion(version)
		my.setType(type)
		my.setIp(ip)
		my.setName(name)
		my.setAddress(address)
		return my
	}
}