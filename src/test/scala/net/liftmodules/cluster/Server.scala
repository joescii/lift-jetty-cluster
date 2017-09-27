package net.liftmodules.cluster

import java.io.{BufferedReader, InputStreamReader}

object Server {
  var process: Option[Process] = None

  def start(): Unit = {
    // Be sure we don't start two
    process.foreach(_ => stop())

    val builder = new ProcessBuilder("./target/universal/stage/bin/lift-jetty-cluster")
    val p = builder.start()
    process = Some(p)

    val stdOut = new BufferedReader(new InputStreamReader(p.getInputStream))
    val lines = Stream.continually(stdOut.readLine()).takeWhile(_ != null)
    val startedLine = lines.find(_.contains("Lift server started on port 8080"))

    println(startedLine)
  }

  def stop(): Unit = {
    process.foreach(_.destroyForcibly())
    process = None
  }

  def restart(): Unit = {
    stop()
    start()
  }
}
