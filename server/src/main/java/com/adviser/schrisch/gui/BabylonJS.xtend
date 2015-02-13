package com.adviser.schrisch.gui

import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.Parentable
import com.adviser.schrisch.model.Rack
import com.fasterxml.jackson.databind.ObjectMapper
import java.util.Collection
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
import java.beans.PropertyChangeListener
import java.beans.PropertyChangeEvent

class BabylonJS extends Composite implements SelectionListener, PropertyChangeListener {

  static final String BABYLON = 'babylon.2.0.js'

  static final String HANDLER = 'handler.js'

  ApplicationContext applicationContext

  final ObjectMapper om = new ObjectMapper()

  DataCenter dataCenter

  final RemoteObject remoteObject

  final OperationHandler operationHandler = new AbstractOperationHandler() {
  }

  new(ApplicationContext applicationContext, Composite parent) {
    super(parent, flags(NONE))
    this.applicationContext = applicationContext
    this.applicationContext.addPropertyChangeListener(this)
    this.applicationContext.selectionManager.addSelectionListener(this)

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

  override onSelectionChanged(Object selection) {
    if (selection instanceof Parentable) {

      // Find selected DataCenter
      var o = selection
      while (o !== null && !(o instanceof DataCenter)) {
        val parent = o.parent
        o = if(parent instanceof Parentable) parent else null
      }
      if (o != null && this.dataCenter != o) {
        setDataCenter(o as DataCenter)
      }
    }
  }

  override propertyChange(PropertyChangeEvent evt) {
    // Trigger redraw
    if(this.dataCenter != null) {
      setDataCenter(this.dataCenter)
    }
  }

  def setDataCenter(DataCenter dataCenter) {
    checkWidget()
    this.dataCenter = dataCenter
    remoteObject.set('dataCenter', om.writeValueAsString(new BabylonJS.ClientDataCenter(dataCenter)))
  }

  override dispose() {
    applicationContext.removePropertyChangeListener(this)
    applicationContext.selectionManager.removeSelectionListener(this)
    remoteObject?.destroy()
    super.dispose()
  }

  static class ClientDataCenter {

    DataCenter delegate

    new(DataCenter dataCenter) {
      this.delegate = dataCenter
    }

    def String getObjectId() { delegate.objectId }

    def String getIdent() { delegate.ident }

    def String getName() { delegate.name }

    def String getStreet() { delegate.street }

    def String getZipCode() { delegate.zipCode }

    def String getCity() { delegate.city }

    def String getCountry() { delegate.country }

    def Collection<ClientRack> getRacks() { delegate.racks.collection.map[new BabylonJS.ClientRack(it)].toList }

  }

  static class ClientRack {

    Rack delegate

    new(Rack rack) {
      delegate = rack
    }

    def String getObjectId() { delegate.objectId }

    def String getIdent() { delegate.ident }

    def String getName() { delegate.name }

    def String getHeight() { delegate.height }

    def String getComment() { delegate.comment }

    def String getRow() { delegate.row }

    def Collection<Content> getContents() { delegate.contents.collection }
  }

}
