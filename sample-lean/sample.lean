import init.system.io data.bert data.parser
import network.n2o.web.http network.n2o.internal
import web.nitro.elements web.nitro.javascript web.nitro.proto
open network.n2o.web.http network.n2o.internal data.bert

inductive Example
| send

instance : BERT Example :=
{ toTerm := λ x ⇒ match x with
  | Example.send ⇒ Term.atom "send",
  fromTerm := λ x ⇒ match x with
  | Term.atom "send" ⇒ Sum.ok Example.send
  | _ ⇒ Sum.fail "invalid Example term" }

def index : Nitro Example → Result
| Nitro.init ⇒ update Example "send" $
  Elem.button "send" [] "Send"
    { source := ["msg"], type := "click", postback := Example.send}
| Nitro.message Example.send query ⇒
  match query.lookup "msg" with
  | some value ⇒ insertBottom Example "hist" (div [] [Elem.liter value])
  | _ ⇒ Result.ok
| Nitro.error s ⇒ Result.ok
| Nitro.ping ⇒ pong
| _ ⇒ Result.ok

def about : Nitro Example → Result
| Nitro.init ⇒ updateText "app" "This is the N2O Hello World App"
| Nitro.ping ⇒ pong
| _ ⇒ Result.ok

def router (cx : Nitro.cx Example) : Nitro.cx Example :=
let handler := match Req.path cx.req with
| "/ws/static/index.html" ⇒ index
| "/ws/static/about.html" ⇒ about
| _ ⇒ index;
⟨cx.req, handler⟩

def handler : Handler := mkHandler (nitroProto Example) [ router ]
def main := startServer handler ("localhost", 9000)
