package code.snippet

import net.liftweb.http.RequestVar
import net.liftweb.http.js.JE.{ElemById, JsNull, JsVal}
import net.liftweb.http.js.JsCmd
import net.liftweb.http.js.JsCmds.{SetHtml, SetValById}
import net.liftweb.util.Helpers._
import net.liftweb.http.SHtml._

import scala.xml.Text

object TestReqVar extends RequestVar[String]("not-set")

class ReqVarSnip {
  def callback(value: String): JsCmd = {
    TestReqVar(value)
    SetHtml("req-var", Text(value)) &
      SetValById("input-text", "")
  }

  def render =
    "#req-var *" #> TestReqVar.get &
    "#update [onclick]" #> ajaxCall(
      (ElemById("input-text") ~> JsVal("value")),
      callback
    ) &
    "#read [onclick]" #> ajaxCall(
      JsNull,
      _ => SetHtml("req-var", Text(TestReqVar.get))
    )
}
