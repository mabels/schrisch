package com.adviser.schrisch.model.dto

import com.adviser.schrisch.gui.ApplicationContext
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import org.apache.lucene.analysis.standard.StandardAnalyzer
import org.apache.lucene.document.Document
import org.apache.lucene.document.Field
import org.apache.lucene.document.StringField
import org.apache.lucene.index.DirectoryReader
import org.apache.lucene.index.IndexWriter
import org.apache.lucene.index.IndexWriterConfig
import org.apache.lucene.queryparser.classic.QueryParser
import org.apache.lucene.search.IndexSearcher
import org.apache.lucene.search.TopScoreDocCollector
import org.apache.lucene.store.RAMDirectory
import org.apache.lucene.util.Version
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class Searcher implements PropertyChangeListener {

  private static final Logger LOGGER = LoggerFactory.getLogger(Searcher)

  val ApplicationContext appContext

  val directory = new RAMDirectory()
  val indexWriterConfig = new IndexWriterConfig(Version.LATEST, new StandardAnalyzer())

  new(ApplicationContext appContext) {
    this.appContext = appContext
    appContext.addPropertyChangeListener(this)
  }

  def search(String q_str) {
    val reader = DirectoryReader.open(directory)
    val searcher = new IndexSearcher(reader)
    val analyzer = new StandardAnalyzer()
    val queryParser = new QueryParser("<default field>", analyzer)
    val collector = TopScoreDocCollector.create(5, true);
    searcher.search(queryParser.parse(q_str), collector);
    val ret = collector.topDocs().scoreDocs;
    reader.close()
    ret

  }

  override propertyChange(PropertyChangeEvent evt) {
    if (evt != null && evt.source != null && evt.newValue != null) {
      val writer = new IndexWriter(directory, indexWriterConfig);
      val doc = new Document();
      val fieldName = evt.propertyName + "@" + evt.source.class.simpleName + "@" + evt.source.hashCode
      LOGGER.debug("propertyChange:"+fieldName)
      doc.add(new StringField(fieldName, evt.newValue.toString, Field.Store.YES))
      writer.addDocument(doc)
      writer.close

    //  LOGGER.debug("search=>"+search("c40"))
    }
  }

}
