package com.adviser.schrisch.gui

import org.eclipse.jface.action.CoolBarManager
import org.eclipse.jface.action.IToolBarManager
import org.eclipse.jface.action.ToolBarManager
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Accessors

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*
import org.eclipse.jface.action.ICoolBarManager

class Workbench {

  @Accessors(PUBLIC_GETTER)
  IToolBarManager toolbar

  @Accessors(PUBLIC_GETTER)
  Composite left

  @Accessors(PUBLIC_GETTER)
  Composite bottom

  new(Composite parent) {
    createControls(parent)
  }

  private def createControls(Composite parent) {
    newComposite(parent, flags(NONE), GridLayoutFactory.fillDefaults.create()) => [
      toolbar = new ToolBarManager() => [ bar |
        bar.createControl(it)
      ]
      newSashForm(it, flags(HORIZONTAL, BORDER)) => [
        layoutData = GridDataFactory.fillDefaults.grab(true, true).create()
        left = newComposite(it, flags(NONE), new FillLayout)
        newSashForm(it, flags(VERTICAL, BORDER)) => [
          newComposite(it, flags(NONE), new FillLayout)
          bottom = newComposite(it, flags(NONE), new FillLayout)
          weights = #[5, 1]
        ]
        weights = #[1, 5]
      ]
    ]
  }

}
