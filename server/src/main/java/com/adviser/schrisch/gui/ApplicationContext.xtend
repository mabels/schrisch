package com.adviser.schrisch.gui

import java.beans.PropertyChangeListener
import java.beans.PropertyChangeSupport
import org.eclipse.xtend.lib.annotations.Accessors
import com.adviser.schrisch.model.dto.Searcher

interface ApplicationContext {

  def Runnable getStopOnCloseCallback()

  def SelectionManager getSelectionManager()

  def void setDoLoad(Runnable action)

  def Runnable getDoLoad()

  def void setDoSave(Runnable action)

  def Runnable getDoSave()

  def void setDoApiLoad(Runnable action)

  def Runnable getDoApiLoad()

  def PropertyChangeListener[] getPropertyChangeListeners()

  def void addPropertyChangeListener(PropertyChangeListener pcl)
}

class ApplicationContextImpl implements ApplicationContext {

  @Accessors
  Runnable stopOnCloseCallback

  @Accessors
  SelectionManager selectionManager

  @Accessors
  Runnable doLoad

  @Accessors
  Runnable doSave

  @Accessors
  Runnable doApiLoad

  @Accessors
  val PropertyChangeSupport propertyChangeSupport = new PropertyChangeSupport(this)

  override getPropertyChangeListeners() {
    propertyChangeSupport.getPropertyChangeListeners()
  }

  override addPropertyChangeListener(PropertyChangeListener pcl) {
    propertyChangeSupport.addPropertyChangeListener(pcl)
  }
  
  val searcher = new Searcher(this)

}
