abbrev Name := String

inductive Attr : Type
| int : Name → Int → Attr
| str : Name → String → Attr
| list : Name → List String → Attr
| noVal : Name → Attr

inductive Elem : Type
| tag : Name → List Attr → List Elem → Elem
| unpaired : Name → List Attr → Elem
| liter : String → Elem

def showAttrValue : Attr → Name × String
| Attr.int name v ⇒ (name, toString v)
| Attr.str name v ⇒ (name, v)
| Attr.list name v ⇒ (name, String.intercalate " " v)
| Attr.noVal name ⇒ (name, "")

def rendNameString : Name × String → String
| (name, "") ⇒ name
| (name, v) ⇒ name ++ "=\"" ++ v ++ "\""

def rendAttr := rendNameString ∘ showAttrValue
def rendAttrs := String.intercalate " " ∘ List.map rendAttr

partial def render : Elem → String
| Elem.tag tag attrs body ⇒
  "<" ++ tag ++ " " ++ rendAttrs attrs ++ ">" ++
  String.join (render <$> body) ++
  "</" ++ tag ++ ">"
| Elem.unpaired tag attrs ⇒
  "<" ++ tag ++ " " ++ rendAttrs attrs ++ " />"
| Elem.liter str ⇒ str
