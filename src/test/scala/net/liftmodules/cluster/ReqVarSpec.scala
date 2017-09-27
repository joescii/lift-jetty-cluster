package net.liftmodules.cluster

class ReqVarSpec extends BaseSpec {
  "The index page" should "load" in {
    go to s"$index/reqvars"
    eventually { textField("the_age").value shouldEqual "0" }
  }

  "Submit" should "work after server is bounced" in {
    Server.restart()

    textField("the_name").value = "joescii"
    textField("the_age").value = "30"
    click on "submit"
    eventually { find(CssSelectorQuery("#lift__noticesContainer___notice li")).head.text shouldEqual "Name: joescii" }
    eventually { find(CssSelectorQuery("#lift__noticesContainer___notice li + li")).head.text shouldEqual "Age: 30" }
  }
}
