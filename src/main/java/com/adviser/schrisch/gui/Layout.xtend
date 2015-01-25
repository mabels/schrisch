package com.adviser.schrisch.gui

import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.rap.rwt.application.AbstractEntryPoint
import org.eclipse.rap.rwt.widgets.DialogUtil
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.MessageBox

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class Layout extends AbstractEntryPoint {

  ApplicationContext applicationContext

  new(ApplicationContext applicationContext) {
    this.applicationContext = applicationContext
  }

  override protected createContents(Composite parent) {
    parent.layout = new FillLayout()
    new Workbench(parent) => [
      toolbar.add(
        new Action(null, ImageDescriptor.createFromURL(class.getResource('/arrow_refresh.png'))) {
          override run() {
            new MessageBox(Display.getCurrent.activeShell, flags(YES)) => [
              message = 'TODO: Reload...'
              DialogUtil.open(it)[]
            ]
          }
        }
      )
      toolbar.add(
        new Action(null, ImageDescriptor.createFromURL(class.getResource('/disk.png'))) {
          override run() {
            new MessageBox(Display.getCurrent.activeShell, flags(YES)) => [
              message = 'TODO: Save...'
              DialogUtil.open(it)[]
            ]
          }
        }
      )
      toolbar.update(true)
      new DataCentersTreeView(applicationContext, left)
      new PropertiesEditor(applicationContext, bottom)
    ]
  }

}
