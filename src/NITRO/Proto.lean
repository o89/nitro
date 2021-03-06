import N2O.Data.BERT
import N2O.Network.Default

inductive Nitro (α : Type)
| init    : Nitro α
| message : α → List (String × String) → Nitro α
| error   : String → Nitro α
| ping    : Nitro α
| done    : Nitro α

def nitroProto (α : Type) [BERT α] : Proto :=
let readQuery : Term → Option (String × String) :=
λ t => match t with
| Term.tuple [ Term.atom name, Term.string value ] => some (name, value)
| _ => none;
{ ev := Nitro α,
  nothing := Result.ok,
  proto := λ p => match p with
    | Msg.binary input =>
      match Parser.run readTerm input with
      | Sum.ok (Term.tuple
          [ Term.atom "pickle", Term.binary target,
            Term.binary termBin, Term.list linked ]) =>
        match Parser.run readTerm termBin with
        | Sum.ok term =>
          match BERT.fromTerm term with
          | Sum.ok v => Nitro.message v (List.filterMap readQuery linked)
          | Sum.fail s => Nitro.error s
        | Sum.fail s => Nitro.error s
      | Sum.ok _ => Nitro.error "unknown term"
      | Sum.fail s => Nitro.error s
    | Msg.text "PING" => Nitro.ping
    | Msg.text "N2O," => Nitro.init
    | _ => Nitro.error "unknown message" }

def ignore {α : Type} [BERT α] : Nitro α → Result :=
uselessRouter (nitroProto α)

def pong := Result.reply (Msg.text "PONG")

def Nitro.cx (α : Type) [BERT α] := Cx (nitroProto α)
