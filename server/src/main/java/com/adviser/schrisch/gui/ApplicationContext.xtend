package com.adviser.schrisch.gui

import com.adviser.schrisch.model.dto.Searcher
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class ApplicationContext {

  Runnable stopOnCloseCallback

  SelectionManager selectionManager

  Runnable doLoad

  Runnable doSave

  Runnable doApiLoad

  Searcher searcher = new Searcher

  Workbench workbench
  
  Object modelRoot = null

}
