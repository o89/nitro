abbrev Name := String

mutual inductive Attr, Elem
with Attr : Type
| int : Name → Int → Attr
| str : Name → String → Attr
| list : Name → List String → Attr
| body : List Elem → Attr
| noVal : Name → Attr
with Elem : Type
| tag : Name → List Attr → Elem
| liter : String → Elem

def div := Elem.tag "div"

def idAttr := Attr.str "id"
def classAttr := Attr.list "class"

def getBody : List Attr → List Elem
| Attr.body x :: _ ⇒ x
| hd :: tl ⇒ getBody tl
| [] ⇒ []

def showAttrValue : Attr → Option (Name × String)
| Attr.int name v ⇒ some (name, toString v)
| Attr.str name v ⇒ some (name, v)
| Attr.list name v ⇒ some (name, String.intercalate " " v)
| Attr.body _ ⇒ none
| Attr.noVal name ⇒ some (name, "")

def rendNameString : Name × String → Option String
| (name, "") ⇒ some name
| (name, v) ⇒ some (name ++ "=\"" ++ v ++ "\"")

def rendAttr (x : Attr) := showAttrValue x >>= rendNameString
def rendAttrs := String.intercalate " " ∘ List.filterMap rendAttr

partial def render : Elem → String
| Elem.tag tag attrs ⇒
  let body := String.join (render <$> getBody attrs);
  let attrs := rendAttrs attrs;
  "<" ++ tag ++ " " ++ attrs ++ ">" ++ body ++ "</" ++ tag ++ ">"
| Elem.liter str ⇒ str

