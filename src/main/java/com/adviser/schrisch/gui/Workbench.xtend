package com.adviser.schrisch.gui

import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Accessors

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class Workbench {

  @Accessors(PUBLIC_GETTER)
  Composite left

  @Accessors(PUBLIC_GETTER)
  Composite bottom

  new(Composite parent) {
    createControls(parent)
  }

  private def createControls(Composite parent) {
    newSashForm(parent, flags(HORIZONTAL, BORDER)) => [
      left = newComposite(it, flags(NONE), new FillLayout)
      newSashForm(it, flags(VERTICAL, BORDER)) => [
        newComposite(it, flags(NONE), new FillLayout)
        bottom = newComposite(it, flags(NONE), new FillLayout)
        weights = #[5, 1]
      ]
      weights = #[1, 5]
    ]
  }

}
