import N2O.Data.BERT

abbrev Name := String

inductive Attr : Type
| int : Name → Int → Attr
| str : Name → String → Attr
| list : Name → List String → Attr
| noVal : Name → Attr

structure Event (α : Type) :=
(source : List String) (type : String) (postback : α)

inductive Elem (α : Type) : Type
| tag      : Name → List Attr → List (Elem α) → Elem α
| button   : Name → List Attr → String → Event α → Elem α
| unpaired : Name → List Attr → Elem α
| liter    : String → Elem α

def showAttrValue : Attr → Name × String
| Attr.int name v => (name, toString v)
| Attr.str name v => (name, v)
| Attr.list name v => (name, String.intercalate " " v)
| Attr.noVal name => (name, "")

def rendNameString : Name × String → String
| (name, "") => name
| (name, v) => name ++ "=\"" ++ v ++ "\""

def rendAttr := rendNameString ∘ showAttrValue
def rendAttrs := String.intercalate " " ∘ List.map rendAttr

def rendEvent {α : Type} [BERT α]
  (target : String) (ev : Event α) : String :=
let join := String.intercalate ",";
let escape := λ s => "'" ++ s ++ "'";
let renderSource :=
λ s => "tuple(atom('" ++ s ++ "'),string(querySourceRaw('" ++ s ++ "')))";
match writeTerm (BERT.toTerm ev.postback) with
| Sum.ok v =>
  "{ var x=qi('" ++ target ++ "'); x && x.addEventListener('" ++ ev.type ++
  "',function(event){ if (validateSources([" ++ join (List.map escape ev.source) ++
  "])) { ws.send(enc(tuple(atom('pickle'),bin('" ++ target ++
  "'),bin(new Uint8Array(" ++ toString v ++ ")),[" ++
  join (List.map renderSource ev.source) ++
  "]))); } else console.log('Validation error'); })}"
| Sum.fail _ => ""

def htmlEscapeTable : List (Char × String) :=
[ ('&', "&amp;"), ('<', "&lt;"),
  ('>', "&gt;"), (Char.ofNat 34, "&quot;"),
  ('\'', "&#x27;"), ('/', "&#x2F;") ]

-- definition through pattern-matching causes lags of typechecker
def htmlEscapeChar (ch : Char) : String :=
Option.getD (htmlEscapeTable.lookup ch) (String.singleton ch)

def htmlEscape : String → String :=
String.foldl (λ s => String.append s ∘ htmlEscapeChar) ""

abbrev Html := String
abbrev Javascript := String

partial def render {α : Type} [BERT α] : Elem α → Html × Javascript
| Elem.tag tag attrs body =>
  let (html, js) := List.unzip (List.map render body);
  ("<" ++ tag ++ " " ++ rendAttrs attrs ++ ">" ++
   String.join html ++
   "</" ++ tag ++ ">", String.join js)
| Elem.button name attrs value ev =>
  ("<button " ++ rendAttrs (Attr.str "id" name :: attrs) ++
   ">" ++ value ++ "</button>",
   rendEvent name ev)
| Elem.unpaired tag attrs =>
  ("<" ++ tag ++ " " ++ rendAttrs attrs ++ " />", "")
| Elem.liter str => (htmlEscape str, "")
