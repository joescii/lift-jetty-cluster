package bootstrap.liftweb

import net.liftweb.common.Loggable
import net.liftweb.util.{StringHelpers, LoggingAutoConfigurer, Props}
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.server.session.{JDBCSessionManager, JDBCSessionIdManager}
import org.eclipse.jetty.webapp.WebAppContext

object Start extends App with Loggable {

  LoggingAutoConfigurer().apply()

  logger.info("run.mode: " + Props.modeName)
  logger.trace("system environment: " + sys.env)
  logger.trace("system props: " + sys.props)
  logger.info("liftweb props: " + Props.props)
  logger.info("args: " + args.toList)

  startLift()
  
  def startLift(): Unit = {
    logger.info("starting Lift server")

    val port = {
      val prop = Props.get("jetty.port", "8080")
      val str = if(prop startsWith "$") System.getenv(prop substring 1) else prop
      str.toInt
    }

    logger.info(s"port number is $port")

    val webappDir: String = Option(this.getClass.getClassLoader.getResource("webapp"))
      .map(_.toExternalForm)
      .filter(_.contains("jar:file:")) // this is a hack to distinguish in-jar mode from "expanded"
      .getOrElse("target/webapp")

    logger.info(s"webappDir: $webappDir")

    val server = new Server(port)
    val context = new WebAppContext(webappDir, Props.get("jetty.contextPath").openOr("/"))

    val workerName = StringHelpers.randomString(10)

    logger.info(s"WorkerName: $workerName")

    val driver = Props.get("session.jdbc.driver").openOrThrowException("Cannot boot without property 'session.jdbc.driver' defined in props file")
    val endpoint = Props.get("session.jdbc.endpoint").openOrThrowException("Cannot boot without property 'session.jdbc.endpoint' defined in props file")
    val idMgr = new JDBCSessionIdManager(server)
    idMgr.setWorkerName(workerName)
    idMgr.setDriverInfo(driver, endpoint)
    idMgr.setScavengeInterval(60)
    server.setSessionIdManager(idMgr)

    val jdbcMgr = new JDBCSessionManager()
    jdbcMgr.setSessionIdManager(server.getSessionIdManager())
    context.getSessionHandler().setSessionManager(jdbcMgr)

    server.setHandler(context)
    server.start()
    logger.info(s"Lift server started on port $port")
    server.join()
  }

}
