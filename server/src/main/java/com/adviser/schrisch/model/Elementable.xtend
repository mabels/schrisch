package com.adviser.schrisch.model

import java.util.List

interface Elementable {
	def List<Pair<String, Object>> getElements()
}