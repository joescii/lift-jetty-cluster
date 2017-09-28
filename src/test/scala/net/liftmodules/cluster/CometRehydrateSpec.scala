package net.liftmodules.cluster

class CometRehydrateSpec extends BaseSpec {
  "The comet page" should "load" in {
    go to s"$index/comet"
    eventually { id("counter").element.text shouldEqual "5" }
  }

  "Comet pushes" should "restart after server is bounced" in {
    val origTime = id("time").element.text

    Server.restart()

    eventually { id("counter").element.text shouldEqual "3" }
  }
}
