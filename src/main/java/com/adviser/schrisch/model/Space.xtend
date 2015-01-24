package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Space extends Base<Spaces> {
	String unit_no
	String atom
	
	new(String unit_no, String atom) {
		this.unit_no = unit_no
		this.atom = atom
	}

}
