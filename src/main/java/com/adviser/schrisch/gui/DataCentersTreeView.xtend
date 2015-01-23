package com.adviser.schrisch.gui

import com.adviser.schrisch.ImportRackTables
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.Rack
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.widgets.Composite

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*
import com.adviser.schrisch.model.Content
import org.eclipse.jface.viewers.ViewerSorter

class DataCentersTreeView implements SelectionProvider {

  ApplicationContext applicationContext

  TreeViewer viewer

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext

    // TODO: cleanup on dispose
    this.applicationContext.selectionManager.provider = this
    createControls(parent)
  }

  private def createControls(Composite parent) {
    viewer = new TreeViewer(parent, flags(V_SCROLL)) => [
      contentProvider = new TreeContentProvider()
      labelProvider = new TreeContentLabelProvider()
      sorter = new ViewerSorter()
      addSelectionChangedListener[e|applicationContext.selectionManager.onSelectionChanged]
      input = ImportRackTables.loadDataCenter()
    ]
  }

  override getSelection() {
    (viewer.selection as IStructuredSelection).firstElement
  }

}

class TreeContentProvider implements ITreeContentProvider {

  override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
  }

  override getChildren(Object parentElement) {
    switch (parentElement) {
      DataCenter: {
        parentElement.racks.values
      }
      Rack: {
        parentElement.contents.values
      }
      default: {
        #[]
      }
    }
  }

  override getElements(Object inputElement) {
    inputElement.children
  }

  override getParent(Object element) {
    switch (element) {
      Rack: {
        element.parent
      }
      Content: {
        element.parent
      }
      default: {
        null
      }
    }
  }

  override hasChildren(Object element) {
    element.children.size > 0
  }

  override dispose() {
  }

}

class TreeContentLabelProvider extends LabelProvider {

  override getText(Object element) {
    switch (element) {
      Rack: {
        element.ident
      }
      Content: {
        element.ident
      }
      default: {
        element.toString
      }
    }
  }

}
