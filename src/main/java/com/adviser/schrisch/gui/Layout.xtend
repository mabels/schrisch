package com.adviser.schrisch.gui

import org.eclipse.rap.rwt.application.AbstractEntryPoint
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite

class Layout extends AbstractEntryPoint {

  ApplicationContext applicationContext

  new(ApplicationContext applicationContext) {
    this.applicationContext = applicationContext
  }

  override protected createContents(Composite parent) {
    parent.layout = new FillLayout()
    new Workbench(parent) => [
      new DataCentersTreeView(applicationContext, left)
      new PropertiesEditor(applicationContext, bottom)
    ]
  }

}
