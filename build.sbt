name := "lift-jetty-cluster-aws"

version := "0.0.1"

organization := "net.liftweb"

scalaVersion := "2.11.7"

resolvers ++= Seq(
  "snapshots" at "https://oss.sonatype.org/content/repositories/snapshots",
  "releases"  at "https://oss.sonatype.org/content/repositories/releases"
)

seq(webSettings :_*)

unmanagedResourceDirectories in Test <+= (baseDirectory) { _ / "src/main/webapp" }

scalacOptions ++= Seq("-deprecation", "-unchecked")

libraryDependencies ++= {
  val liftVersion = "2.6.2"
  val liftEdition = liftVersion.substring(0, 3)
  Seq(
    "net.liftweb"             %% "lift-webkit"                        % liftVersion           % "compile",
    "net.liftmodules"         %% ("lift-jquery-module_"+liftEdition)  % "2.8"                 % "compile",
    "org.eclipse.jetty"       %  "jetty-webapp"                       % "8.1.7.v20120910"     % "container,test",
    "org.eclipse.jetty"       %  "jetty-plus"                         % "8.1.7.v20120910"     % "container,test", // For Jetty Config
    "org.eclipse.jetty.orbit" %  "javax.servlet"                      % "3.0.0.v201112011016" % "container,test" artifacts Artifact("javax.servlet", "jar", "jar"),
    "ch.qos.logback"          %  "logback-classic"                    % "1.0.6"               % "compile",
    "org.specs2"              %% "specs2"                             % "2.3.12"              % "test"
  )
}

