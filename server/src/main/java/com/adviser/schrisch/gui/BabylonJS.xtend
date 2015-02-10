package com.adviser.schrisch.gui

import org.eclipse.rap.rwt.RWT
import org.eclipse.rap.rwt.client.service.JavaScriptLoader
import org.eclipse.rap.rwt.remote.AbstractOperationHandler
import org.eclipse.rap.rwt.remote.OperationHandler
import org.eclipse.rap.rwt.remote.RemoteObject
import org.eclipse.rap.rwt.widgets.WidgetUtil
import org.eclipse.swt.widgets.Composite

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

import static extension com.adviser.schrisch.Utils.*

class BabylonJS extends Composite {

  static final String BABYLON = 'babylon.2.0-beta.js'

  static final String HANDLER = 'handler.js'

  final RemoteObject remoteObject

  final OperationHandler operationHandler = new AbstractOperationHandler() {
  }

  new(Composite parent) {
    super(parent, flags(NONE))

    val resourceManager = RWT.getResourceManager();
    if (!resourceManager.isRegistered(HANDLER)) {
      class.getResourceAsStream('/babylon/' + BABYLON).doTry [
        resourceManager.register(BABYLON, it)
      ]
      class.getResourceAsStream('/babylon/' + HANDLER).doTry [
        resourceManager.register(HANDLER, it)
      ]
    }
    val jsLoader = RWT.getClient().getService(JavaScriptLoader)
    jsLoader.require(resourceManager.getLocation(BABYLON))
    jsLoader.require(resourceManager.getLocation(HANDLER))
    val connection = RWT.getUISession().getConnection()
    remoteObject = connection.createRemoteObject('BabylonWidget')
    remoteObject.setHandler(operationHandler)
    remoteObject.set("parent", WidgetUtil.getId(this))
  }

  override dispose() {
    remoteObject?.destroy()
    super.dispose()
  }

}
