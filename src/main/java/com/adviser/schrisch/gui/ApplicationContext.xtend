package com.adviser.schrisch.gui

import org.eclipse.xtend.lib.annotations.Accessors

interface ApplicationContext {

  def Runnable getStopOnCloseCallback()

  def SelectionManager getSelectionManager()

  def void setDoLoad(Runnable action)

  def Runnable getDoLoad()

  def void setDoSave(Runnable action)

  def Runnable getDoSave()

  def void setDoApiLoad(Runnable action)

  def Runnable getDoApiLoad()
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
}
