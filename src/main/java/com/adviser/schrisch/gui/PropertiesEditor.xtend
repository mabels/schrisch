package com.adviser.schrisch.gui

import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite

import static org.eclipse.swt.SWT.*

import static extension com.adviser.schrisch.gui.SWTExtensions.*

class PropertiesEditor implements SelectionListener {

  ApplicationContext applicationContext

  Button button

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext

    // TODO: dispose listener
    this.applicationContext.selectionManager.addSelectionListener(this)
    createControls(parent)
  }

  private def createControls(Composite parent) {
    button = newButton(parent, flags(NONE), 'No selection') => [
      addSelectionListener[ e |
        println(e)
      ]
    ]
  }

  override onSelectionChanged(Object selection) {
    button.text = selection.toString ?: 'No selection'
  }

}
