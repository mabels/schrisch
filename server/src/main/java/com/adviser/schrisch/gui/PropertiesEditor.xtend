package com.adviser.schrisch.gui

import com.adviser.schrisch.model.Base.ReflectedMutableObject
import com.adviser.schrisch.model.Elementable
import org.eclipse.jface.layout.TableColumnLayout
import org.eclipse.jface.viewers.CheckboxCellEditor
import org.eclipse.jface.viewers.ColumnLabelProvider
import org.eclipse.jface.viewers.ColumnWeightData
import org.eclipse.jface.viewers.EditingSupport
import org.eclipse.jface.viewers.IStructuredContentProvider
import org.eclipse.jface.viewers.TableViewer
import org.eclipse.jface.viewers.TableViewerColumn
import org.eclipse.jface.viewers.TextCellEditor
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.xtend.lib.annotations.Accessors

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class PropertiesView implements View {

  ApplicationContext applicationContext

  new(ApplicationContext applicationContext) {
    this.applicationContext = applicationContext
  }

  override getTitle() {
    'Properties'
  }

  override getFlags() {
    #[NONE]
  }

  override createControls(Composite parent) {
    new PropertiesEditor(applicationContext, parent).control
  }

}

class PropertiesEditor implements SelectionListener {

  ApplicationContext applicationContext

  TableViewer viewer

  @Accessors(PUBLIC_GETTER)
  Control control

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext
    this.applicationContext.selectionManager.addSelectionListener(this)
    control = createControls(parent)
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

  private def getMutable(Object element) {
    val value = (element as Pair<String, Object>).value
    return if (value instanceof ReflectedMutableObject)
      value
    else
      null
  }

  override protected canEdit(Object element) {
    element.mutable !== null
  }

  override protected getCellEditor(Object element) {
    val item = element.mutable
    if (item.type === String)
      new TextCellEditor(viewer.control as Composite)
    else if (item.type === Boolean.TYPE)
      new CheckboxCellEditor(viewer.control as Composite)
  }

  override protected getValue(Object element) {
    val item = element.mutable
    if (item !== null) {
      item.get ?: ''
    } else {
      (element as Pair<String, Object>).value ?: ''
    }
  }

  override protected setValue(Object element, Object value) {
    val item = element.mutable
    if (item !== null) {
      item.set(value)
      viewer.refresh(element)
    }
  }

}
