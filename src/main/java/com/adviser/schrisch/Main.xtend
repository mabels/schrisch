package com.adviser.schrisch

import java.io.File
import java.net.InetSocketAddress
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.servlet.DefaultServlet
import org.eclipse.jetty.servlet.ServletContextHandler
import org.eclipse.jetty.servlet.ServletHolder
import org.eclipse.rap.rwt.application.Application
import org.eclipse.rap.rwt.application.ApplicationConfiguration
import org.eclipse.rap.rwt.engine.RWTServlet
import org.eclipse.rap.rwt.engine.RWTServletContextListener
import org.kohsuke.args4j.CmdLineParser
import org.kohsuke.args4j.Option
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import javax.servlet.ServletException
import java.io.IOException
import org.eclipse.rap.rwt.client.WebClient

class Main {

  private static final Logger LOGGER = LoggerFactory.getLogger(Main)

  @Option(name='-p', aliases='--port', usage='The port to bind to', metaVar='PORT')
  int port = 23456

  def static void main(String[] args) {
    new Main(args)
  }

  new(String[] args) {
    new CmdLineParser(this) => [
      properties.withUsageWidth(80)
      parseArgument(args)
    ]

    val server = new Server(InetSocketAddress.createUnresolved('0.0.0.0', port))
    val context = new ServletContextHandler(ServletContextHandler.SESSIONS)
    context.contextPath = '/'
    context.resourceBase = new File(System.getProperty("java.io.tmpdir"), 'schrisch').absolutePath
    context.setInitParameter(ApplicationConfiguration.CONFIGURATION_PARAM, Main.Configuration.name)
    context.addEventListener(new RWTServletContextListener())
    context.addServlet(new ServletHolder(new RWTServlet()), '/ui')
    context.addServlet(new ServletHolder(new ExtendedDefaultServlet()), '/')
    server.handler = context
    server.start()
    LOGGER.info('''Started server on 'http://0.0.0.0:«port»/' ''')
    server.join()
  }

  static class Configuration implements ApplicationConfiguration {

    override configure(Application application) {
      application.addEntryPoint('/ui', HelloWorld,
        #{
          WebClient.PAGE_TITLE -> 'schrisch - Schrank + Tisch',
          WebClient.BODY_HTML -> '<b>...</b>'
        })
    }

  }

  static class ExtendedDefaultServlet extends DefaultServlet {

    override protected doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      val s = request.servletPath + (request.pathInfo ?: '')
      if (s == '/') {
        response.sendRedirect('/ui')
      } else {
        super.doGet(request, response)
      }
    }

  }

}
