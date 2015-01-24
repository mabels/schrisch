package com.adviser.schrisch.gui

import com.adviser.schrisch.ImportRackTables
import com.adviser.schrisch.model.Content
import com.adviser.schrisch.model.DataCenter
import com.adviser.schrisch.model.Identable
import com.adviser.schrisch.model.Parentable
import com.adviser.schrisch.model.Rack
import com.adviser.schrisch.model.Valueable
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.jface.viewers.ViewerSorter
import org.eclipse.swt.widgets.Composite

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

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
			// TODO: This is too static currently
			input = ImportRackTables.loadDataCenters()
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
			Content: {
				#[
					parentElement.attributes,
					parentElement.ips,
					parentElement.ports,
					parentElement.spaces
				]
			}
			,
			default: {
				if(parentElement instanceof Valueable) {
					return parentElement.values
				}
				return null
			}
		}
	}

	override getElements(Object inputElement) {
		inputElement.children
	}

	override getParent(Object element) {
		(element as Parentable).parent
	}

	override hasChildren(Object element) {
		element.children.size > 0
	}

	override dispose() {
	}

}

class TreeContentLabelProvider extends LabelProvider {

	override getText(Object element) {
		(element as Identable).ident
	}

}
