package net.liftmodules.cluster

class ReqVarStateSpec extends BaseSpec {
  "The ReqVar State page" should "load" in {
    go to s"$index/reqvar-state"
    eventually { id("req-var-in").element.text shouldEqual "not-set" }
  }

  "The variable" should "round trip from the server" in {
    textField("input-text").value = "before"
    click on "update"
    eventually { id("req-var-in").element.text shouldEqual "before" }
  }

  "Read" should "work without refreshing page after server is bounced" in {
    val origTime = id("time").element.text

    Server.restart()

    click on "read"
    eventually { id("req-var-out").element.text shouldEqual "before" }
    eventually { id("time").element.text shouldEqual origTime }
  }
}
