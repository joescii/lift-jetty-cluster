package net.liftmodules.cluster


import org.scalatest._
import concurrent.Eventually
import time._
import selenium._

import org.openqa.selenium._
import firefox.FirefoxDriver
import chrome.ChromeDriver

trait BaseSpec extends FlatSpecLike with Matchers with Eventually with WebBrowser with BeforeAndAfterAll {
  override protected def beforeAll(): Unit = Server.start()
  override protected def afterAll(): Unit = {
    Server.stop()
    close()
  }

  val index = "http://localhost:8080"

  implicit override val patienceConfig = PatienceConfig(timeout = scaled(Span(15, Seconds)), interval = scaled(Span(500, Millis)))

  implicit val webDriver: WebDriver = Option(System.getProperty("net.liftmodules.cluster.test.browser")) match {
    case Some("firefox") => new FirefoxDriver() // Currently only this one will work due to need for drivers of the others.
    case Some("chrome") => new ChromeDriver()
    //    case Some("ie32") => new InternetExplorerDriver()
    //    case Some("ie64") => new InternetExplorerDriver()
    //    case Some("safari") => new SafariDriver()
    case _ => new FirefoxDriver()
  }
}

