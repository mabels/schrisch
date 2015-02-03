package com.adviser.schrisch.gui

import java.awt.Desktop
import java.net.URI
import org.kohsuke.args4j.CmdLineParser
import org.kohsuke.args4j.Option

class Main {

  @Option(name='-p', aliases='--port', usage='The port to bind to', metaVar='PORT')
  int port = 23456

  @Option(name='-q', aliases='--quiet', usage='Does not open the application in a browser')
  boolean quite = false

  @Option(name='-s', aliases='--stop-on-close', usage='Do terminate the server if the browser ui is closed')
  boolean stopOnClose = false

  def static void main(String[] args) {
    new Main(args)
  }

  new(String[] args) {
    new CmdLineParser(this) => [
      properties.withUsageWidth(80)
      parseArgument(args)
    ]

    val server = new Server(port, stopOnClose)
    try {
      server.start [
        if(!quite) {
          val uri = new URI('''http://localhost:«port»''')
          if(Desktop.isDesktopSupported) {
            Desktop.getDesktop().browse(uri)
          } else {
            Runtime.getRuntime().exec("xdg-open " + uri.toURL);
          }
        }
      ]
    } finally {
      server.stop()
      System.exit(0)
    }
  }

}
