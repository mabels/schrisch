package com.adviser.schrisch.gui

import java.util.Collections
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

interface SelectionProvider {

  def Object getSelection()

}

interface SelectionListener {

  def void onSelectionChanged(Object selection)

}

class SelectionManager {

  @Accessors
  SelectionProvider provider

  List<SelectionListener> listeners = Collections.synchronizedList(newArrayList)

  def addSelectionListener(SelectionListener listener) {
    listeners += listener
  }

  def removeSelectionListener(SelectionListener listener) {
    listeners -= listener
  }
  
  def getSelection() {
    provider?.selection
  }

  def void onSelectionChanged() {
    if(provider !== null) {
      val selection = provider.selection
      listeners.forEach [
        onSelectionChanged(selection)
      ]
    }
  }

}
