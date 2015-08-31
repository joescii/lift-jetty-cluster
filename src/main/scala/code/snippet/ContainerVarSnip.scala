package code.snippet

import net.liftweb.http.ContainerVar
import net.liftweb.http.js.JE._
import net.liftweb.http.js.JsCmd
import net.liftweb.http.js.JsCmds.{SetValById, SetExp, SetHtml}
import net.liftweb.util.Helpers._
import net.liftweb.http.SHtml._

import scala.xml.Text

object TestVar extends ContainerVar[String]("not-set")

object ContainerVarSnip {
  def callback(value:String):JsCmd = {
    TestVar(value)
    SetHtml("container-var", Text(value)) &
    SetValById("input-text", "")
  }

  def render =
    "#container-var *" #> TestVar.get &
    "button [onclick]" #> ajaxCall(
      (ElemById("input-text") ~> JsVal("value")),
      callback
    )
}
