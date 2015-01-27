package com.adviser.schrisch.gui

import org.eclipse.rap.rwt.RWT
import org.eclipse.rap.rwt.client.service.JavaScriptLoader
import org.eclipse.rap.rwt.remote.RemoteObject
import org.eclipse.rap.rwt.widgets.WidgetUtil
import org.eclipse.swt.widgets.Composite

import static extension com.adviser.schrisch.Utils.*
import org.eclipse.rap.rwt.remote.OperationHandler
import org.eclipse.rap.rwt.remote.AbstractOperationHandler

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class BabylonJS extends Composite {

  static final String BABYLON = 'babylon.js'
  static final String HANDLER = 'handler.js'

  final RemoteObject remoteObject

  final OperationHandler operationHandler = new AbstractOperationHandler() {
  }

  new(Composite parent) {
    super(parent, flags(NONE))
    val resourceManager = RWT.getResourceManager();
    if(!resourceManager.isRegistered(BABYLON)) {
      class.getResourceAsStream('/babylon/babylon.1.14.js').doTry [
        resourceManager.register(BABYLON, it)
      ]
      class.getResourceAsStream('/babylon/handler.js').doTry [
        resourceManager.register(HANDLER, it)
      ]
    }
    val jsLoader = RWT.getClient().getService(JavaScriptLoader)
    jsLoader.require(resourceManager.getLocation(BABYLON))
    jsLoader.require(resourceManager.getLocation(HANDLER))
    val connection = RWT.getUISession().getConnection()
    remoteObject = connection.createRemoteObject('s2.BabylonJS')
    remoteObject.setHandler(operationHandler)
    remoteObject.set("parent", WidgetUtil.getId(this))
  }

  override dispose() {
    remoteObject?.destroy()
    super.dispose()
  }

}
