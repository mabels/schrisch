package com.adviser.schrisch.gui

import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.Rack
import java.util.ArrayList
import org.eclipse.jface.viewers.ColumnLabelProvider
import org.eclipse.jface.viewers.IStructuredContentProvider
import org.eclipse.jface.viewers.TableViewer
import org.eclipse.jface.viewers.TableViewerColumn
import org.eclipse.jface.viewers.Viewer
import org.eclipse.jface.viewers.ViewerSorter
import org.eclipse.swt.widgets.Composite

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class PropertiesEditor implements SelectionListener {

  ApplicationContext applicationContext

  TableViewer viewer

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext

    // TODO: dispose listener
    this.applicationContext.selectionManager.addSelectionListener(this)
    createControls(parent)
  }

  private def createControls(Composite parent) {
    viewer = new TableViewer(parent, flags(H_SCROLL, V_SCROLL, H_SCROLL, FULL_SELECTION)) => [
      table.headerVisible = true
      table.linesVisible = true
      new TableViewerColumn(it, flags(NONE)) => [
        column.width = 200
        column.text = 'Name'
        labelProvider = new ColumnLabelProvider() {
          override getText(Object element) {
            (element as Pair<String, Object>).key
          }
        }
      ]
      new TableViewerColumn(it, flags(NONE)) => [
        column.width = 200
        column.text = 'Value'
        labelProvider = new ColumnLabelProvider() {
          override getText(Object element) {
            (element as Pair<String, Object>).value?.toString
          }
        }
      ]
      contentProvider = new TableContentProvider()
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
    switch (inputElement) {
      Rack: {
        #[
          'Comment' -> inputElement.comment,
          'Height' -> inputElement.height,
          'Name' -> inputElement.name,
          'Row' -> inputElement.row
        ]
      }
      Content: {
        val result = new ArrayList<Pair<String, Object>>()
        result += 'Asset Number' -> (inputElement.asset_no as Object)
        result += 'Id' -> (inputElement.id as Object)
        result += 'Label' -> (inputElement.label as Object)
        result += 'Name' -> (inputElement.name as Object)
        result += 'Tags' -> (inputElement.tags as Object)
        result += 'Type' -> (inputElement.type as Object)
        result += 'Problems' -> (Boolean.valueOf(inputElement.has_problems) as Object)
        return result
      }
      default: {
        #[]
      }
    }
  }

  override dispose() {
  }

}
