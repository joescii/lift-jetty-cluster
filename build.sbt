val liftVersion = SettingKey[String]("liftVersion", "Full version number of the Lift Web Framework")
val liftEdition = SettingKey[String]("liftEdition", "Lift Edition (short version number to append to artifact name)")

lazy val root = (project in file("."))
  .enablePlugins(JettyPlugin)
  .enablePlugins(JavaAppPackaging)
  .settings(
    name := "lift-jetty-cluster",
    version := "0.0.1",
    organization := "net.liftweb",
    scalaVersion := System.getProperty("scala.version", "2.11.11"),
    liftVersion := System.getProperty("lift.version", "3.2.0-SNAPSHOT"),
    liftEdition := liftVersion.value.replaceAllLiterally("-SNAPSHOT", "").split('.').take(2).mkString("."),
    resolvers ++= Seq(
      "snapshots" at "https://oss.sonatype.org/content/repositories/snapshots",
      "releases"  at "https://oss.sonatype.org/content/repositories/releases"
    ),
    scalacOptions ++= Seq("-deprecation", "-unchecked"),
    libraryDependencies ++= {
      Seq(
        "net.liftweb"             %% "lift-webkit"                              % liftVersion.value     % "compile",
        "net.liftmodules"         %% ("lift-jquery-module_3.1")                 % "2.10"                % "compile",
        "net.liftmodules"         %% ("lift-cluster-kryo_"+liftEdition.value)   % "0.0.2-SNAPSHOT"               % "compile",
        "net.liftmodules"         %% ("lift-cluster-jetty9_"+liftEdition.value) % "0.0.2-SNAPSHOT"               % "compile",
        "org.eclipse.jetty"       %  "jetty-webapp"                             % "9.2.7.v20150116"     % "compile",
        "org.eclipse.jetty"       %  "jetty-plus"                               % "9.2.7.v20150116"     % "container,test", // For Jetty Config
        "org.eclipse.jetty.orbit" %  "javax.servlet"                            % "3.0.0.v201112011016" % "container,test" artifacts Artifact("javax.servlet", "jar", "jar"),
        "org.mariadb.jdbc"        %  "mariadb-java-client"                      % "1.1.8"               % "runtime", // non-GPL alternative for mysql driver
        "ch.qos.logback"          %  "logback-classic"                          % "1.2.3"               % "compile",
        "org.scalatest"           %% "scalatest"                                % "3.0.1"               % "test",
        "org.seleniumhq.selenium" %  "selenium-java"                            % "2.51.0"              % "test"
      )
    },
    bashScriptConfigLocation := Some("${app_home}/../conf/jvmopts"),
    parallelExecution in Test := false
  )




