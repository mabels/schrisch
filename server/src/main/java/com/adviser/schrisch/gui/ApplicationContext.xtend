package com.adviser.schrisch.gui

import com.adviser.schrisch.model.dto.Searcher
import java.beans.PropertyChangeListener
import java.beans.PropertyChangeSupport
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.apache.lucene.search.ScoreDoc
import java.util.List
import org.apache.lucene.document.Document

interface ApplicationContext {

  def Runnable getStopOnCloseCallback()

  def SelectionManager getSelectionManager()

  def void setDoLoad(Runnable action)

  def Runnable getDoLoad()

  def void setDoSave(Runnable action)

  def Runnable getDoSave()

  def void setDoApiLoad(Runnable action)

  def Runnable getDoApiLoad()

  def PropertyChangeListener[] getPropertyChangeListeners()

  def void addPropertyChangeListener(PropertyChangeListener pcl)

  def List<Document> doSearch(String str)
}

class ApplicationContextImpl implements ApplicationContext {
  static final Logger LOGGER = LoggerFactory.getLogger(ApplicationContextImpl)

  @Accessors
  Runnable stopOnCloseCallback

  @Accessors
  SelectionManager selectionManager

  @Accessors
  Runnable doLoad

  @Accessors
  Runnable doSave

  @Accessors
  Runnable doApiLoad

  @Accessors
  val PropertyChangeSupport propertyChangeSupport = new PropertyChangeSupport(this)

  override getPropertyChangeListeners() {
    propertyChangeSupport.getPropertyChangeListeners()
  }

  override addPropertyChangeListener(PropertyChangeListener pcl) {
    propertyChangeSupport.addPropertyChangeListener(pcl)
  }

  val searcher = new Searcher(this)

  override doSearch(String q) {
    LOGGER.debug("searcher=q=" + q)
    val ret = searcher.search(q)
    ret.forEach[doc|
      doc.fields.forEach[f| LOGGER.debug("searcher=>" + f.name+":"+f.stringValue)]
    ] 
    ret   
  }

}
