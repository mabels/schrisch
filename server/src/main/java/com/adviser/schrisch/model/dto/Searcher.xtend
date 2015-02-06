package com.adviser.schrisch.model.dto

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.HashMap
import java.util.List
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
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

import static extension com.adviser.schrisch.Utils.*

class Searcher implements PropertyChangeListener {

  static final Logger LOGGER = LoggerFactory.getLogger(Searcher)

  ExecutorService executor = Executors.newFixedThreadPool(10)

  val directory = new RAMDirectory()

  val indexWriterConfig = new IndexWriterConfig(Version.LATEST, new StandardAnalyzer())

  val source2doc = new HashMap<Object, SourceAndDocument>()

  val writer = new IndexWriter(directory, indexWriterConfig);

  @Data
  static class SourceAndDocument {
    Document document
    Object source
  }

  def List<Document> search(String q_str) {
    DirectoryReader.open(directory).transform [ reader |
      val searcher = new IndexSearcher(reader)
      val analyzer = new StandardAnalyzer()
      val queryParser = new QueryParser("name", analyzer)
      val collector = TopScoreDocCollector.create(5, true);
      searcher.search(queryParser.parse(q_str), collector);
      val ret = collector.topDocs().scoreDocs.map[sd|searcher.doc(sd.doc)]
      ret
    ]
  }

  override propertyChange(PropertyChangeEvent evt) {
    if (evt != null && evt.source != null && evt.newValue != null) {
      var sad = source2doc.get(evt.source)
      val updateAndDocument = if (sad == null) {
          sad = new SourceAndDocument(new Document(), evt.source)
          source2doc.put(evt.source, sad)
          false -> sad.document
        } else {
          true -> sad.document
        }
      val fieldName = evt.propertyName
      if (fieldName.equals("name")) {
        LOGGER.debug("propertyChange:" + fieldName + ":" + evt.newValue.toString)
      }
      sad.document.add(new StringField(fieldName, evt.newValue.toString, Field.Store.YES))
      executor.submit [
        if (updateAndDocument.key) {
          writer.updateDocument(new Term(fieldName), updateAndDocument.value)
        } else {
          writer.addDocument(updateAndDocument.value)
        }
        writer.commit
      ]
    }
  }

}
