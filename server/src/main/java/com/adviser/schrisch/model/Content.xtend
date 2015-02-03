package com.adviser.schrisch.model

import com.adviser.schrisch.Utils
import com.adviser.xtend.annotation.Observable
import com.fasterxml.jackson.annotation.JacksonInject
import com.fasterxml.jackson.annotation.JsonCreator
import java.beans.PropertyChangeListener

@Observable
class Content extends Base {
	String name
	String label
	String asset_no
	String type
	String tags
	boolean has_problems
	String id

	var Spaces spaces
	var Ports ports 
	var Ips ips
	var Attributes attributes

	@JsonCreator
	new(@JacksonInject("pcls") PropertyChangeListener[] pcls) {
		pcls.forEach[pcl|this.addPropertyChangeListener(pcl)]
    spaces = new Spaces(pcls)
    ports = new Ports(pcls)
    ips = new Ips(pcls)
    attributes = new Attributes(pcls)
	}

	static def create(PropertyChangeListener[] pcls, String name, String label, String asset_no, String type, String tags, boolean has_problems,
		String id) {
		val ct = new Content(pcls)
		ct.setName(name)
		ct.setLabel(label)
		ct.setAsset_no(asset_no)
		ct.setType(type)
		ct.setTags(tags)
		ct.setHas_problems(has_problems)
		ct.setId(id)
		return ct
	}

	override getIdent() {
		Utils.clean_fname(
			if(name != null && !name.trim.empty) {
				name.trim
			} else {
				id
			}
		)
	}

	override int hashCode() {
		val prime = 31
		var result = 1
		result = prime * result + if(id == null) 0 else id.hashCode()
		return result
	}

	override equals(Object obj) {
		if(this === obj) return true
		if(obj === null) return false
		if(class !== obj.class) return false
		val other = obj as Content
		if(id != other.id) return false
		return true
	}

}
