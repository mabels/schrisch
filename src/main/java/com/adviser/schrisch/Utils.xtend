package com.adviser.schrisch

class Utils {
	def static clean_fname(String fname) {
  		return fname.toLowerCase.replaceAll("[^a-z0-9]+", '-')
	}
}