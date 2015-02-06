package com.adviser.schrisch.gui

import org.eclipse.jface.action.Action
import org.eclipse.jface.action.ToolBarManager
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*
import org.eclipse.swt.custom.CTabFolder
import org.eclipse.swt.custom.CTabItem
import org.eclipse.swt.widgets.Control

class Workbench {

  static final Logger LOGGER = LoggerFactory.getLogger(Workbench)

  ApplicationContext applicationContext

  @Accessors(PUBLIC_GETTER)
  Composite left

  @Accessors(PUBLIC_GETTER)
  Composite center

  CTabFolder bottom

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
        bar.createControl(it)
      ]
      newSashForm(it, flags(HORIZONTAL, BORDER)) => [
        layoutData = GridDataFactory.fillDefaults.grab(true, true).create()
        left = newComposite(it, flags(NONE), new FillLayout)
        newSashForm(it, flags(VERTICAL, BORDER)) => [
          center = newComposite(it, flags(NONE), new FillLayout)
          bottom = new CTabFolder(it, flags(TOP, FLAT)) => [
            layout = new FillLayout()
            minimizeVisible = false
            maximizeVisible = false
            touchEnabled = true
          ]
          weights = #[6, 2]
        ]
        weights = #[1, 5]
      ]
    ]
  }

  def void addView(View view) {
    new CTabItem(bottom, flags(view.flags)) => [
      text = view.title
      control = view.createControls(bottom)
    ]
    if (bottom.selectionIndex === -1) {
      bottom.selection = 0
    }
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

interface View {

  def String getTitle()

  def int[] getFlags()

  def Control createControls(Composite parent)

}
