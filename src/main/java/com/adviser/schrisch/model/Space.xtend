package com.adviser.schrisch.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Space extends Base {
	String unit_no
	String atom

	static def create(String unit_no, String atom) {
		val my = new Space()
		my.unit_no = unit_no
		my.atom = atom
		return my
	}

}
