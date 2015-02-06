package com.adviser.schrisch.gui

import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.DataCenters
import com.adviser.schrisch.model.Rack
import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.xtend.lib.annotations.Accessors
import com.adviser.schrisch.model.Parentable
import com.adviser.schrisch.model.CollectionBase

class ToolbarAction extends Action {

  @Accessors(PROTECTED_GETTER)
  ApplicationContext applicationContext

  ()=>void callback

  new(ApplicationContext applicationContext, String image) {
    super()
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
  }

  override run() {
    applicationContext.doLoad?.run()
  }

}

class SaveAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/disk.png')
  }

  override run() {
    applicationContext.doSave?.run()
  }

}

class ApiLoadAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/server.png')
  }

  override run() {
    applicationContext.doApiLoad?.run()
  }

}

class DeleteAction extends ToolbarAction {

  new(ApplicationContext applicationContext) {
    super(applicationContext, '/cross.png')
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
        parent.remove(selection)
      }
    }
  }

}

class NewDataCenterAction extends ToolbarAction {
  new(ApplicationContext applicationContext) {
    super(applicationContext, '/building_add.png')
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
