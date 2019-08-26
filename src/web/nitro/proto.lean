import data.bert network.n2o.internal
open data.bert network.n2o.internal

inductive Nitro (α : Type)
| init {} : Nitro
| message : α → Nitro
| error {} : String → Nitro
| done {} : Nitro

def nitroProto (α : Type) [BERT α] : Proto :=
{ prot := Msg,
  ev := Nitro α,
  res := Result,
  req := Req,
  nothing := Result.ok,
  proto := λ p ⇒ match p with
    | Msg.binary data ⇒
      match Parser.run readTerm data with
      | Sum.ok term ⇒
        match BERT.fromTerm term with
        | Sum.ok v ⇒ Nitro.message v
        | Sum.fail s ⇒ Nitro.error s
      | Sum.fail s ⇒ Nitro.error s
    | Msg.text "N2O," ⇒ Nitro.init
    | _ ⇒ Nitro.error "unknown message" }

def Nitro.cx (α : Type) [BERT α] := Cx (nitroProto α)
