package bootstrap.liftweb

import java.net.URI

import net.liftweb.common.Loggable
import net.liftweb.util.{StringHelpers, LoggingAutoConfigurer, Props}
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.server.session.{JDBCSessionManager, JDBCSessionIdManager}
import org.eclipse.jetty.webapp.WebAppContext
import util.Properties

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

    val port = System.getProperty(
      "jetty.port", Properties.envOrElse("PORT", "8080")).toInt

    logger.info(s"port number is $port")

    val webappDir: String = Option(this.getClass.getClassLoader.getResource("webapp"))
      .map(_.toExternalForm)
      .filter(_.contains("jar:file:")) // this is a hack to distinguish in-jar mode from "expanded"
      .getOrElse("target/webapp")

    logger.info(s"webappDir: $webappDir")

    val server = new Server(port)
    val context = new WebAppContext(webappDir, Props.get("jetty.contextPath").openOr("/"))

    if(Props.get("cluster").map(_.equalsIgnoreCase("true")).openOr(false)) {
      val workerName = StringHelpers.randomString(10)

      logger.info(s"WorkerName: $workerName")

      val driver = Props.get("cluster.jdbc.driver").openOrThrowException("Cannot boot in cluster mode without property 'session.jdbc.driver' defined in props file")

      val endpoint = if (System.getenv("CLEARDB_DATABASE_URL") == null) {
        // Non-heroku deployment. Either local or AWS
        val dbHost = Properties.envOrElse("DB_HOST", "127.0.0.1")
        val dbPort = Properties.envOrElse("DB_PORT", "3306")
        s"jdbc:mysql://$dbHost:$dbPort/lift_sessions?user=jetty&password=lift-rocks"
      } else {
        // Heroku deployment
        val dbUri = new URI(System.getenv("CLEARDB_DATABASE_URL"))
        val username = dbUri.getUserInfo.split(":")(0)
        val password = dbUri.getUserInfo.split(":")(1)
        s"jdbc:mysql://${dbUri.getHost}${dbUri.getPath}?user=$username&password=$password&${dbUri.getQuery}"
      }

      val idMgr = new JDBCSessionIdManager(server)
      idMgr.setWorkerName(workerName)
      idMgr.setDriverInfo(driver, endpoint)
      idMgr.setScavengeInterval(60)
      server.setSessionIdManager(idMgr)

      val jdbcMgr = new JDBCSessionManager()
      jdbcMgr.setSessionIdManager(server.getSessionIdManager())
      context.getSessionHandler().setSessionManager(jdbcMgr)
    }

    server.setHandler(context)
    server.start()
    logger.info(s"Lift server started on port $port")
    server.join()
  }

}
