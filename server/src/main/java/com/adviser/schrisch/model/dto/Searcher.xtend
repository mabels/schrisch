package com.adviser.schrisch.model.dto

import com.adviser.schrisch.gui.ApplicationContext
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.HashMap
import org.apache.lucene.analysis.standard.StandardAnalyzer
import org.apache.lucene.document.Document
import org.apache.lucene.document.Field
import org.apache.lucene.document.StringField
import org.apache.lucene.index.DirectoryReader
import org.apache.lucene.index.IndexWriter
import org.apache.lucene.index.IndexWriterConfig
import org.apache.lucene.index.Term
import org.apache.lucene.queryparser.classic.QueryParser
import org.apache.lucene.search.IndexSearcher
import org.apache.lucene.search.TopScoreDocCollector
import org.apache.lucene.store.RAMDirectory
import org.apache.lucene.util.Version
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.util.List

class Searcher implements PropertyChangeListener {

  private static final Logger LOGGER = LoggerFactory.getLogger(Searcher)

  val ApplicationContext appContext

  val directory = new RAMDirectory()
  val indexWriterConfig = new IndexWriterConfig(Version.LATEST, new StandardAnalyzer())
  
 
  @Data
  static class SourceAndDocument {
    Document document
    Object source
  }
  val source2doc = new HashMap<Object, SourceAndDocument>()

  new(ApplicationContext appContext) {
    this.appContext = appContext
    appContext.addPropertyChangeListener(this)
  }

  def List<Document> search(String q_str) {
    val reader = DirectoryReader.open(directory)
    val searcher = new IndexSearcher(reader)
    val analyzer = new StandardAnalyzer()
    val queryParser = new QueryParser("name", analyzer)
    val collector = TopScoreDocCollector.create(5, true);
    searcher.search(queryParser.parse(q_str), collector);
    val ret = collector.topDocs().scoreDocs.map[sd| searcher.doc(sd.doc) ]
    reader.close()
    ret

  }

  val writer = new IndexWriter(directory, indexWriterConfig);
  
  override propertyChange(PropertyChangeEvent evt) {
    if (evt != null && evt.source != null && evt.newValue != null) {
      var update = true
      var sad = source2doc.get(evt.source)
      if (sad == null) {
        sad = new SourceAndDocument(new Document(), evt.source)
        source2doc.put(evt.source, sad)
        update = false
      } 
      val fieldName = evt.propertyName
      if (fieldName.equals("name")) {
        LOGGER.debug("propertyChange:"+fieldName+":"+evt.newValue.toString)
      }
      sad.document.add(new StringField(fieldName, evt.newValue.toString, Field.Store.YES))
      if (update) {      
         writer.updateDocument(new Term(fieldName), sad.document)
      } else {
        writer.addDocument(sad.document)
      }
      writer.commit
      //writer.close

    //  LOGGER.debug("search=>"+search("c40"))
    }
  }

}
