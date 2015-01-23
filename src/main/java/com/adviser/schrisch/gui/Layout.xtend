package com.adviser.schrisch.gui

import org.eclipse.rap.rwt.application.AbstractEntryPoint
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite

import static org.eclipse.swt.SWT.*

import static extension com.adviser.schrisch.gui.SWTExtensions.*

class Layout extends AbstractEntryPoint {

  override protected createContents(Composite parent) {
    parent.layout = new FillLayout()
    new Workbench(parent) => [
      new DataCentersTreeView(left)
      // TODO: Add properties-editor here
      newButton(bottom, flags(NONE), 'Click me 2') => [
        addSelectionListener[ e |
          println(e)
        ]
      ]
    ]
  }

}
