package com.adviser.schrisch.model.dto

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.HashMap
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import java.util.concurrent.ConcurrentHashMap
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
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import com.adviser.schrisch.model.Base
import java.util.Arrays

class DocumentCollector {
  val fields = new ConcurrentHashMap<String, PropertyChangeEvent>()
  val Base model

  new(Base _model) {
    model = _model
  }

  def getModel() {
    return model
  }

  def getFields() {
    fields
  }

  def setField(PropertyChangeEvent pce) {
    fields.put(pce.propertyName, pce)
  }
}

class SearchProcessor implements Runnable {
  static final Logger LOGGER = LoggerFactory.getLogger(SearchProcessor)

  val Searcher searcher
  val thread = new Thread(this)

  new(Searcher _searcher) {
    searcher = _searcher
  }

  static def start(Searcher searcher) {
    val sp = new SearchProcessor(searcher)
    sp.thread.start
    return sp
  }

  override run() {
    while(true) {
      val work = searcher.resetToProcess
      if(!work.values.empty) {
        LOGGER.debug("process " + work.values.size + " documents into index")
      }
      work.values.forEach [ dc |
        searcher.writer.deleteDocuments(new Term("hashCode", dc.model.hashCode.toString))
        val doc = new Document()
        LOGGER.debug("hashcode="+dc.model.hashCode.toString+" ident="+dc.model.ident+
                     " class="+dc.model.class.name)
        doc.add(new StringField("hashCode", dc.model.hashCode.toString, Field.Store.YES))
        doc.add(new StringField("ident", dc.model.ident, Field.Store.YES))
        dc.fields.values.forEach [ pct |
          doc.add(new StringField(pct.propertyName, pct.newValue.toString, Field.Store.YES))
        ]
        searcher.writer.addDocument(doc)
      ]
      if(!work.values.empty) {
        searcher.writer.commit
      }
      Thread.sleep(1000);
    }
  }

}

class Result {

  // I need the list of the matched field
  val Base model

  new(Base _model) {
    model = _model
  }

  def getModel() {
    model
  }
}

class Searcher implements PropertyChangeListener {
  static final Logger LOGGER = LoggerFactory.getLogger(SearchProcessor)

  val directory = new RAMDirectory()

  val indexWriterConfig = new IndexWriterConfig(Version.LATEST, new StandardAnalyzer())

  val source2doc = new HashMap<String, DocumentCollector>()

  val writer = new IndexWriter(directory, indexWriterConfig);

  val toProcessMutex = new Object
  var toProcess = new HashMap<String, DocumentCollector>()

  val searchProcessor = SearchProcessor.start(this);

  val fieldList = new HashSet<String>(Arrays.asList("hashCode", "ident"))

  def resetToProcess() {
    synchronized(toProcessMutex) {
      val ret = toProcess
      toProcess = new HashMap<String, DocumentCollector>()
      return ret
    }
  }

  def getWriter() {
    writer
  }

  def List<Result> search(String q_str, int resultCount) {
    val reader = DirectoryReader.open(directory)
    val searcher = new IndexSearcher(reader)
    val analyzer = new StandardAnalyzer()
    val queryParser = new MultiFieldQueryParser(fieldList, analyzer)
    val collector = TopScoreDocCollector.create(resultCount, true);
    searcher.search(queryParser.parse(q_str), collector);
    val ret = new LinkedList<Result>()
    LOGGER.debug(">>>" + fieldList)
    collector.topDocs().scoreDocs.forEach [ sd |
      var field = searcher.doc(sd.doc).getField("hashCode")
      val hashCode = field.stringValue
      val dc = source2doc.get(hashCode)
      ret.push(new Result(dc.model))
    ]
    reader.close
    ret
  }

  override propertyChange(PropertyChangeEvent evt) {
    if(evt != null && evt.source != null && evt.newValue != null) {
      var DocumentCollector dc
      synchronized(source2doc) {
        source2doc.get(evt.source.hashCode.toString)
        if(dc == null) {
          dc = new DocumentCollector(evt.source as Base)
          source2doc.put(evt.source.hashCode.toString, dc)
        }
      }
      synchronized(toProcessMutex) {
        toProcess.put(evt.source.hashCode.toString, dc)
      }
      dc.setField(evt)
      fieldList.add(evt.propertyName)
    }
  }

}
