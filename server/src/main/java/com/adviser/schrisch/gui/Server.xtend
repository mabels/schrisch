package com.adviser.schrisch.gui

import java.io.File
import java.io.IOException
import java.net.InetSocketAddress
import javax.servlet.ServletException
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.eclipse.jetty.servlet.DefaultServlet
import org.eclipse.jetty.servlet.ServletContextHandler
import org.eclipse.jetty.servlet.ServletHolder
import org.eclipse.rap.rwt.application.Application
import org.eclipse.rap.rwt.application.ApplicationConfiguration
import org.eclipse.rap.rwt.client.WebClient
import org.eclipse.rap.rwt.engine.RWTServlet
import org.eclipse.rap.rwt.engine.RWTServletContextListener
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class Server {

  private static final Logger LOGGER = LoggerFactory.getLogger(Server)

  int port

  static Runnable stopOnCloseCallback

  static org.eclipse.jetty.server.Server server

  new(int port, boolean stopOnCloseEnabled) {
    this.port = port
    if(stopOnCloseEnabled) {
      stopOnCloseCallback = [
        val t = new Thread [
          Thread.sleep(1000)
          server.stop()
        ]
        t.daemon = true
        t.start()
      ]
    }
  }

  def start(()=>void afterStartCallback) {
    server = new org.eclipse.jetty.server.Server(InetSocketAddress.createUnresolved('0.0.0.0', port))
    val context = new ServletContextHandler(ServletContextHandler.SESSIONS)
    context.contextPath = '/'
    context.resourceBase = new File(System.getProperty("java.io.tmpdir"), 'schrisch').absolutePath
    context.setInitParameter(ApplicationConfiguration.CONFIGURATION_PARAM, Configuration.name)
    context.addEventListener(new RWTServletContextListener())
    context.addServlet(new ServletHolder(new RWTServlet()), '/ui')
    context.addServlet(new ServletHolder(new ExtendedDefaultServlet()), '/')
    server.handler = context
    server.start()
    LOGGER.info('''Started server on 'http://0.0.0.0:«port»/' ''')
    afterStartCallback?.apply()
    server.join()
  }

  def stop() {
    server.stop()
  }

  static class Configuration implements ApplicationConfiguration {

    override configure(Application application) {
      application.addEntryPoint('/ui',
        [
          val context = new ApplicationContextImpl() => [
            it.stopOnCloseCallback = stopOnCloseCallback
            selectionManager = new SelectionManager()
          ]
          return new Layout(context)
        ],
        #{
          WebClient.PAGE_TITLE -> 'schrisch - Schrank + Tisch',
          WebClient.BODY_HTML -> '<b>...</b>'
        })
    }

  }

  static class ExtendedDefaultServlet extends DefaultServlet {

    override protected doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      val s = request.servletPath + (request.pathInfo ?: '')
      if(s == '/') {
        response.sendRedirect('/ui')
      } else {
        super.doGet(request, response)
      }
    }

  }

}
