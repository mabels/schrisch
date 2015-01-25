package com.adviser.schrisch.gui

import com.adviser.schrisch.model.Base.ReflectedMutableObject
import com.adviser.schrisch.model.Elementable
import org.eclipse.jface.layout.TableColumnLayout
import org.eclipse.jface.viewers.ColumnLabelProvider
import org.eclipse.jface.viewers.ColumnWeightData
import org.eclipse.jface.viewers.EditingSupport
import org.eclipse.jface.viewers.IStructuredContentProvider
import org.eclipse.jface.viewers.TableViewer
import org.eclipse.jface.viewers.TableViewerColumn
import org.eclipse.jface.viewers.TextCellEditor
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.widgets.Composite

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class PropertiesEditor implements SelectionListener {

  ApplicationContext applicationContext

  TableViewer viewer

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext
    this.applicationContext.selectionManager.addSelectionListener(this)
    createControls(parent)
  }

  private def createControls(Composite parent) {
    val layout = new TableColumnLayout()
    newComposite(parent, flags(NONE), layout) => [
      addDisposeListener[
        applicationContext.selectionManager.removeSelectionListener(this)
      ]
      viewer = new TableViewer(it, flags(H_SCROLL, V_SCROLL, H_SCROLL, FULL_SELECTION)) => [
        val viewer = it
        table.headerVisible = true
        table.linesVisible = true
        new TableViewerColumn(it, flags(NONE)) => [
          column.text = 'Name'
          layout.setColumnData(column, new ColumnWeightData(1, true))
          labelProvider = new ColumnLabelProvider() {
            override getText(Object element) {
              (element as Pair<String, Object>).key
            }
          }
        ]
        new TableViewerColumn(it, flags(NONE)) => [
          column.text = 'Value'
          layout.setColumnData(column, new ColumnWeightData(1, true))
          labelProvider = new ColumnLabelProvider() {
            override getText(Object element) {
              (element as Pair<String, Object>).value?.toString
            }
          }
          editingSupport = new StringValueEditingSupport(viewer)
        ]
        contentProvider = new TableContentProvider()
      ]
    ]
  }

  override onSelectionChanged(Object selection) {
    viewer.input = selection
  }

}

class TableContentProvider implements IStructuredContentProvider {

  override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
  }

  override getElements(Object inputElement) {
    (inputElement as Elementable).elements
  }

  override dispose() {
  }

}

class StringValueEditingSupport extends EditingSupport {

  new(TableViewer viewer) {
    super(viewer)
  }

  override protected canEdit(Object element) {
    (element as Pair<String, Object>).value instanceof ReflectedMutableObject
  }

  override protected getCellEditor(Object element) {
    new TextCellEditor(viewer.control as Composite)
  }

  override protected getValue(Object element) {
    val item = (element as Pair<String, Object>).value
    if(item instanceof ReflectedMutableObject) {
      item.get?.toString
    } else {
      item?.toString
    }
  }

  override protected setValue(Object element, Object value) {
    val item = (element as Pair<String, Object>).value
    if(item instanceof ReflectedMutableObject) {
      item.set(value)
      viewer.refresh(element)
    }
  }

}
