package com.adviser.schrisch.gui

import java.util.List
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.widgets.Composite
import org.eclipse.xtend.lib.annotations.Accessors

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class DataCentersTreeView {

  new(Composite parent) {
    createControls(parent)
  }

  private def createControls(Composite parent) {
    new TreeViewer(parent, flags(V_SCROLL)) => [
      contentProvider = new TreeContentProvider()
      labelProvider = new LabelProvider()
      addSelectionChangedListener[ e |
        val selection = (e.selection as IStructuredSelection).firstElement
      ]
      // TODO: This is the dummy-tree
      input = new TreeItem(null, 'root') => [ root |
        (0 .. 50).forEach [ i |
          root.children += new TreeItem(root, '''Item «i»''') => [ item |
            (0 .. 10).forEach [ j |
              item.children += new TreeItem(item, '''SubItem «i».«j»''')
            ]
          ]
        ]
      ]
    ]
  }

}

class TreeContentProvider implements ITreeContentProvider {

  override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
  }

  override getChildren(Object parentElement) {
    (parentElement as TreeItem).children
  }

  override getElements(Object inputElement) {
    inputElement.children
  }

  override getParent(Object element) {
    (element as TreeItem).parent
  }

  override hasChildren(Object element) {
    (element as TreeItem).children.size > 0
  }

  override dispose() {
  }

}

class TreeItem {

  String name

  @Accessors
  TreeItem parent

  @Accessors
  List<TreeItem> children = newArrayList

  new(TreeItem parent, String name) {
    this.parent = parent
    this.name = name
  }

  override toString() {
    name
  }

}
