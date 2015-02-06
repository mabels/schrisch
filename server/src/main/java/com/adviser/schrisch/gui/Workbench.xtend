package com.adviser.schrisch.gui

import com.google.common.collect.BiMap
import com.google.common.collect.HashBiMap
import java.util.List
import org.eclipse.jface.action.Action
import org.eclipse.jface.action.ToolBarManager
import org.eclipse.jface.layout.GridDataFactory
import org.eclipse.jface.layout.GridLayoutFactory
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.swt.custom.CTabFolder
import org.eclipse.swt.custom.CTabFolder2Adapter
import org.eclipse.swt.custom.CTabFolderEvent
import org.eclipse.swt.custom.CTabItem
import org.eclipse.swt.layout.FillLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static com.adviser.schrisch.gui.SWTExtensions.*
import static org.eclipse.swt.SWT.*

class Workbench {

  static final Logger LOGGER = LoggerFactory.getLogger(Workbench)

  ApplicationContext applicationContext

  @Accessors(PUBLIC_GETTER)
  Composite left

  @Accessors(PUBLIC_GETTER)
  Composite center

  CTabFolder bottom

  BiMap<View, CTabItem> views = HashBiMap.create()

  new(ApplicationContext applicationContext, Composite parent) {
    this.applicationContext = applicationContext
    createControls(parent)
  }

  private def createControls(Composite parent) {
    newComposite(parent, flags(NONE), GridLayoutFactory.fillDefaults.create()) => [
      new ToolBarManager() => [ bar |
        bar.add(new ToolbarAction('/arrow_refresh.png')[applicationContext.doLoad?.run()])
        bar.add(new ToolbarAction('/disk.png')[applicationContext.doSave?.run()])
        bar.add(new ToolbarAction('/server.png')[applicationContext.doApiLoad?.run()])
        bar.createControl(it)
      ]
      newSashForm(it, flags(HORIZONTAL, BORDER)) => [
        layoutData = GridDataFactory.fillDefaults.grab(true, true).create()
        left = newComposite(it, flags(NONE), new FillLayout)
        newSashForm(it, flags(VERTICAL, BORDER)) => [
          center = newComposite(it, flags(NONE), new FillLayout)
          bottom = it.createBottomTabFolder()
          weights = #[6, 2]
        ]
        weights = #[1, 5]
      ]
    ]
  }

  private def createBottomTabFolder(Composite parent) {
    new CTabFolder(parent, flags(TOP, FLAT)) => [
      layout = new FillLayout()
      minimizeVisible = false
      maximizeVisible = false
      touchEnabled = true
      addCTabFolder2Listener(
        new CTabFolder2Adapter() {
          override close(CTabFolderEvent event) {
            val item = event.item as CTabItem
            val view = views.inverse.remove(item)
            view.removeViewUpdateListener(item.getData('listener') as ViewUpdateListener)
          }
        })
    ]
  }

  def void addView(View view, boolean open) {
    val item = new CTabItem(bottom, flags(view.flags)) => [
      val ViewUpdateListener listener = [
        text = view.title
      ]
      control = view.createControls(bottom)
      listener.onUpdate()
      view.addViewUpdateListener(listener)
      setData('listener', listener)
    ]
    views.put(view, item)
    if (bottom.selectionIndex === -1 || open) {
      bottom.selection = bottom.items.indexOf(item)
    }
  }

  def void showView(View view) {
    val item = views.get(view)
    bottom.selection = bottom.items.indexOf(item)
  }

  def getViews() {
    views.keySet.unmodifiableView
  }

  static class ToolbarAction extends Action {

    ()=>void callback

    new(String image, ()=>void callback) {
      super()
      this.callback = callback
      imageDescriptor = ImageDescriptor.createFromURL(class.getResource(image))
    }

    override run() {
      callback.apply()
    }

  }

}

interface View {

  def String getTitle()

  def int[] getFlags()

  def Control createControls(Composite parent)

  def void addViewUpdateListener(ViewUpdateListener listener)

  def void removeViewUpdateListener(ViewUpdateListener listener)

}

abstract class AbstractView implements View {

  List<ViewUpdateListener> listeners = newArrayList

  override addViewUpdateListener(ViewUpdateListener listener) {
    listeners += listener
  }

  override removeViewUpdateListener(ViewUpdateListener listener) {
    listeners -= listener
  }

  def void update() {
    listeners.forEach [
      onUpdate()
    ]
  }

}

interface ViewUpdateListener {

  def void onUpdate()

}
