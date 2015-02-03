package com.adviser.schrisch.model

import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonIgnore
import java.beans.PropertyChangeListener

@Observable
class DataCenter extends Base {
	String name
	String street
	String zipCode
	String city
	String country

	@JsonIgnore
	var Racks racks

	@JsonCreator
	new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
		pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
		racks = new Racks(pcls)
	}

	override getIdent() {
		if(name != null) {
			name
		} else {
			name = "" + hashCode
		}
	}

	override int hashCode() {
		val prime = 31
		var result = 1
		result = prime * result + if(name == null) 0 else name.hashCode()
		return result
	}

	override equals(Object obj) {
		if(this === obj) return true
		if(obj === null) return false
		if(class !== obj.class) return false
		val other = obj as DataCenter
		if(name != other.name) return false
		return true
	}

}
