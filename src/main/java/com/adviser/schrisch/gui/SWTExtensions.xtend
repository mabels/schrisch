package com.adviser.schrisch.gui

import org.eclipse.swt.custom.SashForm
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display

import static extension com.adviser.schrisch.Utils.*

class SWTExtensions {

  def static flags(int... flags) {
    flags.fold(0)[acc, f|acc.bitwiseOr(f)]
  }

  def static newComposite(Composite parent, int flags, org.eclipse.swt.widgets.Layout layout) {
    new Composite(parent, flags) => [
      it.layout = layout
    ]
  }

  def static newSashForm(Composite parent, int flags) {
    new SashForm(parent, flags) => [
      touchEnabled = true
    ]
  }

  def static newButton(Composite parent, int flags, String text) {
    new Button(parent, flags) => [
      it.text = text
    ]
  }

  def static addSelectionListener(Button button, (SelectionEvent)=>void handler) {
    button.addSelectionListener(
      new SelectionAdapter() {
        override widgetSelected(SelectionEvent e) {
          handler.apply(e)
        }
      });
  }

  def static newImage(String path) {
    SWTExtensions.getResourceAsStream(path).transform [
      new Image(Display.getCurrent(), it)
    ]
  }

}
