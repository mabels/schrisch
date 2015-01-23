package com.adviser.schrisch.gui

import org.eclipse.xtend.lib.annotations.Accessors

interface ApplicationContext {

  def SelectionManager getSelectionManager()

}

class ApplicationContextImpl implements ApplicationContext {

  @Accessors
  SelectionManager selectionManager

}
