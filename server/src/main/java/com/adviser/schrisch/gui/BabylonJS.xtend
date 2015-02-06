package com.adviser.schrisch.gui

import org.eclipse.rap.rwt.remote.AbstractOperationHandler
import org.eclipse.rap.rwt.remote.OperationHandler
import org.eclipse.swt.widgets.Composite

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class BabylonJS extends Composite {

  static final String BABYLON = 'babylon.js'
  static final String HANDLER = 'handler.js'
  static final String HANDJS = 'hand.js'

  //final RemoteObject remoteObject
  final OperationHandler operationHandler = new AbstractOperationHandler() {
  }

  new(Composite parent) {
    super(parent, flags(NONE))

  /*
    val resourceManager = RWT.getResourceManager();
    if(!resourceManager.isRegistered(BABYLON)) {
      class.getResourceAsStream('/babylon/babylon.1.14.js').doTry [
        resourceManager.register(BABYLON, it)
      ]
      class.getResourceAsStream('/babylon/hand-1.3.8.js').doTry [
        resourceManager.register(HANDJS, it)
      ]
      class.getResourceAsStream('/babylon/handler.js').doTry [
        resourceManager.register(HANDLER, it)
      ]
    }
    val jsLoader = RWT.getClient().getService(JavaScriptLoader)
    jsLoader.require(resourceManager.getLocation(HANDJS))
    jsLoader.require(resourceManager.getLocation(BABYLON))
    jsLoader.require(resourceManager.getLocation(HANDLER))
    val connection = RWT.getUISession().getConnection()
    remoteObject = connection.createRemoteObject('s2.BabylonJS')
    remoteObject.setHandler(operationHandler)
    remoteObject.set("parent", WidgetUtil.getId(this))
    */
  }

  override dispose() {

    //remoteObject?.destroy()
    super.dispose()
  }

}
