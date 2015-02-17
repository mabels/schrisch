package com.adviser.schrisch.model

import java.beans.PropertyChangeListener
import java.beans.PropertyChangeSupport

interface AddPropertyChangeListener {
  def void addPropertyChangeListener(PropertyChangeListener pcl)
  def PropertyChangeSupport getPropertyChangeSupport()
}