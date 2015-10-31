package code.comet

import net.liftweb.http.CometActor
import net.liftweb.http.js.JsCmds
import net.liftweb.util.Schedule

import scala.xml.NodeSeq

class CounterComet extends CometActor {
  override def lowPriority = {
    case i:Int => partialUpdate(JsCmds.SetHtml("counter", <span>{i}</span>))
  }

  override def render = NodeSeq.Empty

  def increment(i:Int):Unit = {
    this ! i
    Schedule(() => increment(i + 1), 1000)
  }

  increment(0)
}
