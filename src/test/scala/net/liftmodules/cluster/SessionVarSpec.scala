package net.liftmodules.cluster

class SessionVarSpec extends BaseSpec {
  "The index page" should "load" in {
    go to index
    eventually { id("container-var").element.text shouldEqual "not-set" }
  }

  "The variable" should "round trip from the server" in {
    textField("input-text").value = "before"
    click on "update-button"
    eventually { id("container-var").element.text shouldEqual "before" }
  }

  "Submit" should "work without refreshing page after server is bounced" in {
    val origTime = id("time").element.text

    Server.restart()

    textField("input-text").value = "after"
    click on "update-button"
    eventually { id("container-var").element.text shouldEqual "after" }
    eventually { id("time").element.text shouldEqual origTime }
  }
}
