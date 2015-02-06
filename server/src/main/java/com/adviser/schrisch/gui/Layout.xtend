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
    new Workbench(applicationContext, parent) => [
      new DataCentersTreeView(applicationContext, left)
      new BabylonJS(center)
      addView(new PropertiesView(applicationContext))
    ]
    shell.display.disposeExec [
      applicationContext.stopOnCloseCallback?.run()
    ]
  }

}
