package com.adviser.schrisch

import org.eclipse.rap.rwt.application.AbstractEntryPoint
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label

class HelloWorld extends AbstractEntryPoint {

  override protected createContents(Composite parent) {
    val label = new Label(parent, SWT.NONE);
    label.setText('Hello RAP World');
  }

}
