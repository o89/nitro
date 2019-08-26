import init.system.io data.bert data.parser
import network.n2o.web.http network.n2o.internal
import web.nitro.elements web.nitro.javascript web.nitro.proto
open network.n2o.web.http network.n2o.internal data.bert

inductive Example | send

instance : BERT Example :=
{ toTerm := λ x ⇒ match x with
  | Example.send ⇒ Term.atom "send",
  fromTerm := λ x ⇒ match x with
  | Term.atom "send" ⇒ Sum.ok Example.send
  | _ ⇒ Sum.fail "invalid Example term" }

def index : Nitro Example → Result
| Nitro.init ⇒ insertBottom "hist" (div [] [ Elem.liter "hello" ])
| Nitro.message Example.send ⇒ Result.ok
| _ ⇒ Result.ok

def about : Nitro Example → Result
| Nitro.init ⇒ updateText "app" "This is the N2O Hello World App"
| _ ⇒ Result.ok

def router (cx : Nitro.cx Example) : Nitro.cx Example :=
let handler := match Req.path cx.req with
| "/ws/static/index.html" ⇒ index
| "/ws/static/about.html" ⇒ about
| _ ⇒ index;
⟨cx.req, handler⟩

def handler : Handler := mkHandler (nitroProto Example) [ router ]
def main := startServer handler ("localhost", 9000)
