package com.adviser.schrisch.gui

import java.io.File
import java.net.URL
import java.net.URLClassLoader
import org.kohsuke.args4j.CmdLineParser
import org.kohsuke.args4j.Option
import com.google.common.io.Resources
import java.io.FileOutputStream

class Main {

  @Option(name='-h', aliases='--headless', usage='Start without ui')
  boolean headless = false

  @Option(name='-p', aliases='--port', usage='The port to bind to', metaVar='PORT')
  int port = 23456

  File temp

  def static void main(String[] args) {
    new Main(args)
  }

  new(String[] args) {
    new CmdLineParser(this) => [
      properties.withUsageWidth(80)
      parseArgument(args)
    ]

    temp = new File(System.getProperty("java.io.tmpdir"), 'schrisch')
    temp.mkdirs()

    if(true || headless) {
      val server = server()
      try {
        Thread.currentThread.contextClassLoader = server.class.classLoader
        server.start()
      } finally {
        server.stop()
      }
    } else {
      val server = server()
      val thread = new Thread [
        Thread.currentThread.contextClassLoader = server.class.classLoader
        server.start()
      ]
      thread.start()
      Thread.sleep(2000)
      try {
        client().start()
      } finally {
        server.stop()
      }
      System.exit(0)
    }
  }

  def server() {
    createClassLoader('swt-rwt.jar', 'swt-rwt-jface.jar').loadClass('''«class.package.name».Server''').
      getConstructor(Integer.TYPE).newInstance(port)
  }

  def client() {
    createClassLoader('swt-linux.jar').loadClass('''«class.package.name».Client''').getConstructor(Integer.TYPE).
      newInstance(port)
  }

  private def createClassLoader(String... jars) {
    val files = jars.map[new File(temp, it)]
    files.forEach[Resources.copy(class.getResource('/lib/' + name), new FileOutputStream(it))]
    val sysclasspath = System.getProperty('java.class.path').split(':').filter[!it.contains('rap')].map[
      new URL('file:' + if(it.endsWith('.jar')) it else it + '/')]
    new PluginClassLoader(files.map[it.toURI.toURL] + sysclasspath)
  }

  private def start(Object o) {
    o.class.getMethod('start').invoke(o)
  }

  private def stop(Object o) {
    o.class.getMethod('stop').invoke(o)
  }

  static class PluginClassLoader extends URLClassLoader {

    new(URL[] urls) {
      super(urls)
    }

    override loadClass(String name) {
      var loadedClass = findLoadedClass(name)
      if(loadedClass == null) {
        try {
          loadedClass = findClass(name)
        } catch(ClassNotFoundException e) {
        }
        if(loadedClass == null) {
          loadedClass = super.loadClass(name)
        }
      }
      return loadedClass
    }

  }

}
