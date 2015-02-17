package com.adviser.schrisch.gui

import com.adviser.schrisch.model.Attribute
import com.adviser.schrisch.model.Attributes
import com.adviser.schrisch.model.CollectionBase
import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.DataCenters
import com.adviser.schrisch.model.Ip
import com.adviser.schrisch.model.Ips
import com.adviser.schrisch.model.Parentable
import com.adviser.schrisch.model.Port
import com.adviser.schrisch.model.Ports
import com.adviser.schrisch.model.Rack
import com.adviser.schrisch.model.Space
import com.adviser.schrisch.model.Spaces
import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.jface.action.IAction
import com.adviser.schrisch.model.Identable
import com.adviser.schrisch.model.Base

class ToolbarAction extends Action {

  @Accessors(PROTECTED_GETTER)
  ApplicationContext applicationContext

  ()=>void callback

  new(ApplicationContext applicationContext, String image) {
    super()
    this.applicationContext = applicationContext
    imageDescriptor = ImageDescriptor.createFromURL(class.getResource(image))
  }

  new(ApplicationContext applicationContext, String image, int style) {
    super(null, style)
    this.applicationContext = applicationContext
    imageDescriptor = ImageDescriptor.createFromURL(class.getResource(image))
  }

  new(ApplicationContext applicationContext, String image, ()=>void callback) {
    this(applicationContext, image)
    this.callback = callback
  }

  override run() {
    callback?.apply()
  }

}

class LoadAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/arrow_refresh.png')
    toolTipText = 'Load from disk'
  }

  override run() {
    applicationContext.doLoad?.run()
  }

}

class SaveAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/disk.png')
    toolTipText = 'Save to disk'
  }

  override run() {
    applicationContext.doSave?.run()
  }

}

class ApiLoadAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/server.png')
    toolTipText = 'Load from webservice'
  }

  override run() {
    applicationContext.doApiLoad?.run()
  }

}

class DeleteAction extends ToolbarAction {

  new(ApplicationContext applicationContext) {
    super(applicationContext, '/cross.png')
    toolTipText = 'Delete selected element'
    enabled = false
    applicationContext.selectionManager.addSelectionListener [ selection |
      enabled = selection !== null
    ]
  }

  override run() {
    val selection = applicationContext.selectionManager.selection
    if (selection instanceof Parentable) {
      val parent = selection.parent
      if (parent instanceof CollectionBase) {
        parent.remove(selection as Base)
      }
    }
  }

}

class NewDataCenterAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/building_add.png')
    toolTipText = 'Add new DataCenter'
  }

  override run() {
    val root = applicationContext.modelRoot
    if (root instanceof DataCenters) {
      root.add(new DataCenter(root.propertyChangeListeners))
    }
  }

}

class NewRackAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/server_add.png')
    toolTipText = 'Add new Rack'
    enabled = false
    applicationContext.selectionManager.addSelectionListener [ selection |
      enabled = selection instanceof DataCenter
    ]
  }

  override run() {
    val dataCenter = applicationContext.selectionManager.selection as DataCenter
    dataCenter.racks.add(new Rack(dataCenter.propertyChangeListeners))
  }

}

class NewContentAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/drive_add.png')
    toolTipText = 'Add new Content'
    enabled = false
    applicationContext.selectionManager.addSelectionListener [ selection |
      enabled = selection instanceof Rack
    ]
  }

  override run() {
    val rack = applicationContext.selectionManager.selection as Rack
    rack.contents.add(new Content(rack.propertyChangeListeners))
  }

}

class NewSpaceAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/missing.png')
    toolTipText = 'Add new Space'
    enabled = false
    applicationContext.selectionManager.addSelectionListener [ selection |
      enabled = selection instanceof Spaces
    ]
  }

  override run() {
    val spaces = applicationContext.selectionManager.selection as Spaces
    spaces.add(new Space(spaces.propertyChangeListeners))
  }

}

class NewIpAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/link_add.png')
    toolTipText = 'Add new Ip'
    enabled = false
    applicationContext.selectionManager.addSelectionListener [ selection |
      enabled = selection instanceof Ips
    ]
  }

  override run() {
    val ips = applicationContext.selectionManager.selection as Ips
    ips.add(new Ip(ips.propertyChangeListeners))
  }

}

class NewPortAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/disconnect.png')
    toolTipText = 'Add new Port'
    enabled = false
    applicationContext.selectionManager.addSelectionListener [ selection |
      enabled = selection instanceof Ports
    ]
  }

  override run() {
    val ports = applicationContext.selectionManager.selection as Ports
    ports.add(new Port(ports.propertyChangeListeners))
  }

}

class NewAttributeAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/table_add.png')
    toolTipText = 'Add new Attribute'
    enabled = false
    applicationContext.selectionManager.addSelectionListener [ selection |
      enabled = selection instanceof Attributes
    ]
  }

  override run() {
    val attributes = applicationContext.selectionManager.selection as Attributes
    attributes.add(new Attribute(attributes.propertyChangeListeners))
  }

}

class ToggleRenderAction extends ToolbarAction {

  new(ApplicationContext applicationContext) {
    super(applicationContext, '/world.png', IAction.AS_CHECK_BOX)
    checked = true
  }

  override run() {
    applicationContext.doTriggerRender.run
  }

}
