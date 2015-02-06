package com.adviser.schrisch.model.dto

import com.adviser.schrisch.gui.ApplicationContext
import com.adviser.schrisch.model.Base
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Set
import org.apache.lucene.analysis.standard.StandardAnalyzer
import org.apache.lucene.document.Document
import org.apache.lucene.document.Field
import org.apache.lucene.document.StringField
import org.apache.lucene.index.DirectoryReader
import org.apache.lucene.index.IndexWriter
import org.apache.lucene.index.IndexWriterConfig
import org.apache.lucene.index.Term
import org.apache.lucene.queryparser.classic.MultiFieldQueryParser
import org.apache.lucene.search.IndexSearcher
import org.apache.lucene.search.TopScoreDocCollector
import org.apache.lucene.store.RAMDirectory
import org.apache.lucene.util.Version
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.util.LinkedList
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue

class Searcher implements PropertyChangeListener {

  private static final Logger LOGGER = LoggerFactory.getLogger(Searcher)

  val ApplicationContext appContext

  val directory = new RAMDirectory()
  val indexWriterConfig = new IndexWriterConfig(Version.LATEST, new StandardAnalyzer())

  @Data
  static class SourceAndDocument {
    Document document
    Base source

  }

  val source2doc = new HashMap<String, SourceAndDocument>()
  val Set<String> fieldNames = new HashSet<String>()
  val writer = new IndexWriter(directory, indexWriterConfig)

  new(ApplicationContext appContext) {
    this.appContext = appContext
    appContext.addPropertyChangeListener(this)
    writer.commit
  }

  def List<Base> search(String q_str) {
    val DirectoryReader reader = DirectoryReader.open(directory)

    val searcher = new IndexSearcher(reader)
    val analyzer = new StandardAnalyzer()
    val queryParser = new MultiFieldQueryParser(fieldNames, analyzer)
    val collector = TopScoreDocCollector.create(5, true);
    searcher.search(queryParser.parse(q_str), collector);
    val ret = new LinkedList<Base>()
    collector.topDocs().scoreDocs.forEach [ sd |
      val doc = searcher.doc(sd.doc)
      var field = searcher.doc(sd.doc).getField("hashCode")
      val hashCode = field.stringValue
      var found = source2doc.get(hashCode)
      val my = found.source
      LOGGER.debug("my=" + my)
      ret.push(my)
    ]
    reader.close()
    ret

  }

  //  reader.close()
  val queue = new LinkedBlockingQueue<SourceAndDocument>()

  override propertyChange(PropertyChangeEvent evt) {
    var sad = source2doc.get(evt.source.hashCode.toString)
    if(sad == null) {
      sad = new SourceAndDocument(new Document(), evt.source as Base)
      source2doc.put(evt.source.hashCode.toString, sad)
    }
    queue.add(sad);
  }
  
  def queue() {
    new Thread(new Runnable() {
    
    override run() {
      while(true) {
        var i = queue.length
        val sads = new HashSet<SourceAndDocument>()
        while (0 != i--) {
          sads.add(queue.poll())
        }
        sads.forEach[t|
          
        ]
      }
    }
    
    }).start
    if(evt != null && evt.source != null && evt.newValue != null) {
      val reader = DirectoryReader.open(directory)
      var update = true
      var sad = source2doc.get(evt.source.hashCode.toString)
      if(sad == null) {
        sad = new SourceAndDocument(new Document(), evt.source as Base)
        sad.document.add(new StringField("hashCode", evt.source.hashCode.toString, Field.Store.YES))
        fieldNames.add('hashCode')
        source2doc.put(evt.source.hashCode.toString, sad)
        update = false
      }
      val fieldName = evt.propertyName

      //      if (fieldName.equals("name")) {
      //        LOGGER.debug("propertyChange:"+fieldName+":"+evt.newValue.toString)
      //      }
      fieldNames.add(fieldName);
      sad.document.add(new StringField(fieldName, evt.newValue.toString, Field.Store.YES))

      //      if (update) { 
      writer.deleteDocuments(new Term("hashCode", sad.source.hashCode.toString))

      //         writer.updateDocument(new Term(sad.document.doc), sad.document)
      //      } else {
      writer.addDocument(sad.document)

      //      }
      writer.commit

      //writer.close
      reader.close

    //  LOGGER.debug("search=>"+search("c40"))
    }
  }

}
