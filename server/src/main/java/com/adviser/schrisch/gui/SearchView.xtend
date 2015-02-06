package com.adviser.schrisch.gui

import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Accessors

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*
import org.eclipse.swt.widgets.Control

class SearchView extends AbstractView {

  @Accessors
  String text

  Control control

  def void setText(String text) {
    this.text = text
    update()
  }

  override getTitle() {
    '''Search '«text»' '''
  }

  override getFlags() {
    #[CLOSE]
  }

  override createControls(Composite parent) {
    control = newComposite(parent, flags(NONE), new FillLayout)
  }

}
