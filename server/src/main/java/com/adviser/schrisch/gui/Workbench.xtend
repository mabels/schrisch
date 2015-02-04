package com.adviser.schrisch.gui

import org.eclipse.jface.action.Action
import org.eclipse.jface.action.ControlContribution
import org.eclipse.jface.action.ToolBarManager
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.swt.SWT
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.graphics.Point
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Text
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*
import org.slf4j.Logger

class Workbench {
  static final Logger LOGGER = LoggerFactory.getLogger(Server)
  ApplicationContext applicationContext

  @Accessors(PUBLIC_GETTER)
  Composite left

  @Accessors(PUBLIC_GETTER)
  Composite center

  @Accessors(PUBLIC_GETTER)
  Composite bottom

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext
    createControls(parent)
  }

  private def createControls(Composite parent) {
    newComposite(parent, flags(NONE), GridLayoutFactory.fillDefaults.create()) => [
      new ToolBarManager() => [ bar |
        bar.add(new ToolbarAction('/arrow_refresh.png')[applicationContext.doLoad?.run()])
        bar.add(new ToolbarAction('/disk.png')[applicationContext.doSave?.run()])
        bar.add(new ToolbarAction('/server.png')[applicationContext.doApiLoad?.run()])
        bar.add(new ControlContribution("searchText") {

            override protected createControl(Composite parent) {
              val ret = new Text(parent, SWTExtensions.flags(SWT.SINGLE, SWT.BORDER))
              ret.size = new Point(200, 8)
              ret.addSelectionListener(
                new SelectionAdapter() {
                  override widgetDefaultSelected(SelectionEvent e) {
                    Workbench.this.applicationContext.doSearch(ret.text)
                  }
                });
              ret
            }

          })
        //bar.add(new ToolbarAction('/server.png')[applicationContext.doSearch?.run()])
        bar.createControl(it)
      ]
      newSashForm(it, flags(HORIZONTAL, BORDER)) => [
        layoutData = GridDataFactory.fillDefaults.grab(true, true).create()
        left = newComposite(it, flags(NONE), new FillLayout)
        newSashForm(it, flags(VERTICAL, BORDER)) => [
          center = newComposite(it, flags(NONE), new FillLayout)
          bottom = newComposite(it, flags(NONE), new FillLayout)
          weights = #[5, 1]
        ]
        weights = #[1, 5]
      ]
    ]
  }

  static class ToolbarAction extends Action {

    ()=>void callback

    new(String image, ()=>void callback) {
      super()
      this.callback = callback
      imageDescriptor = ImageDescriptor.createFromURL(class.getResource(image))
    }

    override run() {
      callback.apply()
    }

  }

}
