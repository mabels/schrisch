package com.adviser.schrisch.model.dto

import com.adviser.schrisch.model.Base
import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.Arrays
import java.util.HashMap
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import org.apache.lucene.analysis.standard.StandardAnalyzer
import org.apache.lucene.document.Document
import org.apache.lucene.document.Field
import org.apache.lucene.document.StringField
import org.apache.lucene.index.DirectoryReader
import org.apache.lucene.index.IndexWriter
import org.apache.lucene.index.IndexWriterConfig
import org.apache.lucene.index.Term
import org.apache.lucene.queryparser.classic.MultiFieldQueryParser
import org.apache.lucene.queryparser.classic.QueryParser
import org.apache.lucene.search.BooleanClause
import org.apache.lucene.search.IndexSearcher
import org.apache.lucene.search.TopScoreDocCollector
import org.apache.lucene.store.RAMDirectory
import org.apache.lucene.util.Version
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import com.adviser.schrisch.model.Base.ReflectedMutableObject

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
      if(work != null) {
        LOGGER.debug("process " + work.values.size + " documents into index")
        work.forEach [ oid, model |
          searcher.resetObjectId(oid, model.objectId)
          searcher.writer.deleteDocuments(new Term("objectId", model.objectId))
          val doc = new Document()
          doc.add(new StringField("objectId", model.objectId, Field.Store.YES))
          doc.add(new StringField("class", model.class.name, Field.Store.YES))
          doc.add(new StringField("ident", model.ident, Field.Store.YES))
          model.elements.forEach [ pair |
            val _ = pair.value as ReflectedMutableObject
            try {
              //LOGGER.debug("==>"+pair.key+":"+model.class.simpleName+":"+_.get.class.simpleName)
              //LOGGER.debug("==>"+pair.key+":"+model.class.name+":"+_.get.class.name+":"+_.get)
              if (_.toString != null) {
                //LOGGER.debug("==<"+pair.key+":"+model.class.name)
                doc.add(new StringField(pair.key, _.get.toString, Field.Store.YES))
              }
            } catch (Exception e) {
              LOGGER.error("WTF"+e)
            }
          ]
          //        LOGGER.debug("objectId="+model.objectId+" ident="+model.ident+
          //                     " class="+model.class.simpleName+" fields=["+doc.fields.map[t|t.name+"{"+t.stringValue+"}"].join("|")+"]")
          searcher.writer.addDocument(doc)
        ]
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

  val source2model = new HashMap<String, Base>()

  val writer = new IndexWriter(directory, indexWriterConfig);

  val toProcessMutex = new Object
  var toProcess = new HashMap<String, Base>()

  val searchProcessor = SearchProcessor.start(this);

  val fieldList = new HashSet<String>(Arrays.asList("objectId", "ident"))

  def resetToProcess() {
    synchronized(toProcessMutex) {
      if(toProcess.empty) {
        return null
      }
      val ret = toProcess
      toProcess = new HashMap<String, Base>()
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

    //val queryParser = new MultiFieldQueryParser(fieldList, analyzer)
    val collector = TopScoreDocCollector.create(resultCount, true);
    val flags = fieldList.map[s|BooleanClause.Occur.SHOULD]
    val parser = new MultiFieldQueryParser(fieldList, analyzer)
    parser.defaultOperator = QueryParser.Operator.OR
    val query = parser.parse(q_str)
    searcher.search(query, collector);
    val ret = new LinkedList<Result>()
    //LOGGER.debug(">>>" + fieldList + ">>>" + query.toString)
    collector.topDocs().scoreDocs.forEach [ sd |
      val doc = searcher.doc(sd.doc)
      var field = doc.getField("objectId")
      val objectId = field.stringValue
      val model = source2model.get(objectId)
      //LOGGER.debug("RESULT=>" + objectId + ":" + model +":"+ doc.getField("class"))
      if(model != null) {
        ret.push(new Result(model))
      }
    ]
    reader.close
    ret
  }

  override propertyChange(PropertyChangeEvent evt) {
    if(evt != null && evt.source != null && evt.newValue != null) {
      val model = evt.source as Base
      synchronized(source2model) {
        if(source2model.get(model.objectId) == null) {
          //LOGGER.debug("MAP=>"+model.objectId+":"+model.ident+":"+model.class.name)
          source2model.put(model.objectId, model)
        }
      }
      synchronized(toProcessMutex) {
        toProcess.put(model.objectId, model)
      }
      fieldList.add(evt.propertyName)
    }
  }
  
  def resetObjectId(String orig, String real) {
    if (orig != real) {
      synchronized(source2model) {
        val base = source2model.remove(orig)
        source2model.put(real, base)
      }
    }
  }

}
