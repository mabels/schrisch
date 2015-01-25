package com.adviser.schrisch.gui

import org.eclipse.swt.browser.Browser
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Shell

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class Client {

  int port

  new(int port) {
    this.port = port
  }

  def start() {
    val display = new Display()
    val shell = new Shell(display) => [
      layout = new FillLayout()
      maximized = true
      new Browser(it, flags(NONE)) => [
        url = '''http://localhost:«port»'''
      ]
      open()
    ]
    while(!shell.disposed) {
      if(!display.readAndDispatch) {
        display.sleep()
      }
    }
    display.dispose()
  }

}
