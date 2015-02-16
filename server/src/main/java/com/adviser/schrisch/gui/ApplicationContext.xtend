package com.adviser.schrisch.gui

import com.adviser.schrisch.model.dto.Searcher
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.beans.PropertyChangeSupport
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class ApplicationContext implements PropertyChangeListener {

  final PropertyChangeSupport pcs = new PropertyChangeSupport(this);

  Runnable stopOnCloseCallback

  SelectionManager selectionManager

  Runnable doLoad

  Runnable doSave

  Runnable doApiLoad

  Searcher searcher = new Searcher

  Workbench workbench

  Object modelRoot = null
  
  boolean loadingModel = false

  new() {
    addPropertyChangeListener(searcher)
  }

  def void addPropertyChangeListener(PropertyChangeListener listener) {
    this.pcs.addPropertyChangeListener(listener)
  }

  def void removePropertyChangeListener(PropertyChangeListener listener) {
    this.pcs.removePropertyChangeListener(listener)
  }

  override propertyChange(PropertyChangeEvent evt) {
    if (loadingModel) {
      searcher.propertyChange(evt)
    } else {
      pcs.firePropertyChange(evt)
    }
  }

}
