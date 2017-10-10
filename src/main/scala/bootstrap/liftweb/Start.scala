package bootstrap.liftweb

import net.liftmodules.cluster.jetty9._
import net.liftweb.common.Loggable
import net.liftweb.util.{LoggingAutoConfigurer, Props, StringHelpers}

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
    val port = System.getProperty(
      "jetty.port", Properties.envOrElse("PORT", "8080")).toInt

    logger.info(s"port number is $port")

    val contextPath = Props.get("jetty.contextPath").openOr("/")

    val maybeClusterConfig = if(Props.get("cluster").map(_.equalsIgnoreCase("true")).openOr(false)) {
      val dbHost = Properties.envOrElse("DB_HOST", "127.0.0.1")
      val dbPort = Properties.envOrElse("DB_PORT", "3306").toInt
      val endpoint: SqlEndpointConfig = SqlEndpointConfig.forHeroku.openOr(
        SqlEndpointConfig.forMySQL(dbHost, dbPort, "lift_sessions", "jetty", "lift-rocks")
      )
      val workerName = StringHelpers.randomString(10)

      logger.info(s"WorkerName: $workerName")

      val driver = DriverMariaDB

      Some(Jetty9ClusterConfig(workerName, DriverMariaDB, endpoint))
    } else None

    val startConfig = Jetty9Config(
      port = port,
      contextPath = contextPath,
      clusterConfig = maybeClusterConfig,
      webappPath = "/opt/docker/webapp"
    )

    Jetty9Starter.start(startConfig)
  }

}
