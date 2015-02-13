package com.adviser.schrisch.gui

import com.adviser.schrisch.Config
import com.adviser.schrisch.model.Attributes
import com.adviser.schrisch.model.Base
import com.adviser.schrisch.model.CollectionBase
import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.DataCenters
import com.adviser.schrisch.model.Identable
import com.adviser.schrisch.model.Ips
import com.adviser.schrisch.model.Parentable
import com.adviser.schrisch.model.Ports
import com.adviser.schrisch.model.Rack
import com.adviser.schrisch.model.Valueable
import com.adviser.schrisch.model.dto.RackTablesApi
import com.adviser.schrisch.model.dto.Result
import com.adviser.schrisch.model.dto.SchrischFileApi
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.Collections
import java.util.List
import java.util.Set
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TreePath
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.jface.viewers.ViewerSorter
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Text
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static org.eclipse.swt.SWT.*

import static extension com.adviser.schrisch.gui.SWTExtensions.*

class DataCentersTreeView implements SelectionProvider, PropertyChangeListener {

  static final Logger LOGGER = LoggerFactory.getLogger(DataCentersTreeView)

  ApplicationContext applicationContext

  Text searchBox

  TreeViewer viewer

  TreeContentProvider contentProvider

  TreePath[] expanded

  boolean isLoading = false

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext
    this.applicationContext.addPropertyChangeListener(this)
    this.applicationContext.selectionManager.provider = this
    
    this.applicationContext.doLoad = [
      isLoading = true
      viewer.input = SchrischFileApi.read(#[applicationContext])
      applicationContext.modelRoot = viewer.input
      val selection = viewer.selection
      viewer.setSelection(selection, true)
      isLoading = false
    ]
    this.applicationContext.doSave = [
      SchrischFileApi.write(viewer.input as DataCenters)
    ]
    this.applicationContext.doApiLoad = [
      viewer.input = RackTablesApi.loadFromRackTables(Config.load, #[applicationContext])
      applicationContext.modelRoot = viewer.input
      val selection = viewer.selection
      viewer.setSelection(selection, true)
    ]
    createControls(parent)
  }

  private def createControls(Composite parent) {
    newComposite(parent, flags(NONE), new GridLayout) => [ composite |
      newComposite(composite, flags(NONE), new GridLayout(2, false)) => [
        layoutData = GridDataFactory.fillDefaults.grab(true, false).create()
        searchBox = new Text(it, flags(SEARCH, ICON_SEARCH, ICON_CANCEL)) => [
          layoutData = GridDataFactory.fillDefaults.grab(true, false).create()
          addDefaultSelectionListener[ e |
            if (e.detail === ICON_CANCEL) {
              searchBox.text = ''
            } else {
              doSearch()
            }
          ]
          addModifyListener[ e |
            doSearch()
          ]
        ]
      ]
      viewer = new TreeViewer(composite, flags(V_SCROLL)) => [
        control.layoutData = GridDataFactory.fillDefaults.grab(true, true).create()
        useHashlookup = true
        contentProvider = new TreeContentProvider()
        it.contentProvider = contentProvider
        labelProvider = new TreeContentLabelProvider()
        sorter = new ViewerSorter()
        addSelectionChangedListener[e|applicationContext.selectionManager.onSelectionChanged]
        tree.addDisposeListener[dispose()]
      ]
    ]
    applicationContext.doLoad.run()
  }

  private def doSearch() {
    if (!searchBox.text.nullOrEmpty && searchBox.text.length > 1) {
      if (expanded === null) {
        expanded = viewer.expandedTreePaths
      }
      try {
        val results = applicationContext.searcher.search(searchBox.text ?: '', 5)
        contentProvider.searchResults = results ?: #[]
        results.forEach [
          viewer.expandToLevel(model, 0)
        ]
      } catch (Exception e) {
        LOGGER.error("Search Exception:" + e.message)
      }
    } else {
      contentProvider.searchResults = null
      if (expanded !== null) {
        viewer.expandedTreePaths = expanded
        expanded = null
      }
    }
    viewer.refresh()
  }

  override propertyChange(PropertyChangeEvent evt) {
    if (!isLoading) {
      val src = evt.source
      if (src instanceof CollectionBase) {
        switch (evt.propertyName) {
          case 'add': {
            viewer.refresh()
            viewer.expandToLevel(src, 1)
          }
          case 'remove':
            viewer.refresh(src, true)
          default:
            viewer.update(src, null)
        }
      } else {
        viewer.update(src, null)
      }
    }
  }

  private def dispose() {
    this.applicationContext.removePropertyChangeListener(this)
    this.applicationContext.selectionManager.provider = null
  }

  override getSelection() {
    (viewer.selection as IStructuredSelection).firstElement
  }

}

class TreeContentProvider implements ITreeContentProvider {

  Set<Base> searchLeaf = Collections.emptySet()

  Set<Object> visibleElements

  def setSearchResults(List<Result> results) {
    searchLeaf = results?.map[model]?.toSet() ?: Collections.emptySet()
    visibleElements = results?.visibleObjects
  }

  override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
  }

  override getChildren(Object parentElement) {
    val elements = switch (parentElement) {
      DataCenter:
        parentElement.racks.values
      Rack:
        parentElement.contents.values
      Content:
        #[
          parentElement.attributes,
          parentElement.ips,
          parentElement.ports,
          parentElement.spaces
        ]
      Valueable:
        parentElement.values
      default:
        return null
    }
    return if (searchLeaf.contains(parentElement))
      elements
    else
      elements.filter [
        if(visibleElements !== null) visibleElements.contains(it) else true
      ]
  }

  override getElements(Object inputElement) {
    inputElement.children
  }

  override getParent(Object element) {
    switch (element) {
      Rack:
        (element.parent as Parentable).parent
      Content:
        (element.parent as Parentable).parent
      Parentable:
        element.parent
    }
  }

  override hasChildren(Object element) {
    element?.children?.size > 0
  }

  override dispose() {
  }

  private def visibleObjects(List<Result> results) {
    val Set<Object> set = newHashSet
    results.forEach [
      val model = it.model
      set += model
      if (model instanceof Parentable) {
        var parent = model.parent
        while (parent !== null) {
          set += parent
          parent = if (parent instanceof Parentable) {
            parent.parent
          }
        }
      }
    ]
    return set
  }

}

class TreeContentLabelProvider extends LabelProvider {

  override getImage(Object element) {
    switch (element) {
      DataCenter:
        newImage('/building.png')
      Rack:
        newImage('/server.png')
      Content:
        newImage('/drive.png')
      Attributes:
        newImage('/table.png')
      Ports:
        newImage('/connect.png')
      Ips:
        newImage('/link.png')
      default:
        null
    }
  }

  override getText(Object element) {
    switch (element) {
      Identable:
        element.ident
      default:
        element?.toString ?: ''
    }
  }

}
