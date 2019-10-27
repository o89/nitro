import Network.N2O
import Web.NITRO.Elements

def action (x : String) : Result :=
let term := λ b ⇒ Term.tuple
  [ Term.atom "io",
    Term.binary b,
    Term.binary ByteArray.empty ];
match Put.run (Put.unicode x) with
| Sum.ok bytes ⇒
  match writeTerm (term bytes) with
  | Sum.ok v ⇒ Result.reply (Msg.binary v)
  | Sum.fail s ⇒ Result.error s
| Sum.fail s ⇒ Result.error s

variables (α : Type) [BERT α]

def update (target : String) (elem : Elem α) : Result :=
let (html, js) := render elem;
action $ "qi('" ++ target ++ "').outerHTML='" ++ html ++ "';" ++ js

def updateText (target text : String) : Result :=
action $ "qi('" ++ target ++ "').innerText='" ++ text ++ "';"

def insertTagTop (tag target : String) (elem : Elem α) : Result :=
let (html, js) := render elem;
action $
  "qi('" ++ target ++ "').insertBefore(" ++
  "(function(){ var div = qn('" ++ tag ++ "'); div.innerHTML = '" ++
  html ++ "'; return div.firstChild; })()," ++
  "qi('" ++ target ++ "').firstChild);" ++ js

def insertTagBottom (tag target : String) (elem : Elem α) : Result :=
let (html, js) := render elem;
action $
  "(function(){ var div = qn('" ++ tag ++
  "'); div.innerHTML = '" ++ html ++
  "';qi('" ++ target ++ "').appendChild(div.firstChild); })();" ++ js

def insertTop := insertTagTop α "div"
def insertBottom := insertTagBottom α "div"

def insertAdjacent (position target : String) (elem : Elem α) :=
let (html, js) := render elem;
action $
  "qi('" ++ target ++ "').insertAdjacentHTML('" ++
  position ++ "', '" ++ html ++ "');" ++ js

def insertBefore := insertAdjacent α "beforebegin"
def insertAfter := insertAdjacent α "afterend"

def clear (target : String) :=
action $
  "(function(){var x = qi('" ++ target ++
  "'); while (x.firstChild) x.removeChild(x.firstChild);})();"

def remove (target : String) :=
action $
  "(function(){var x=qi('" ++ target ++
  "'); x && x.parentNode.removeChild(x);})();"

def redirect (url : String) :=
action $ "(function(){document.location = '" ++ url ++ "';})();"

def display (elem status : String) :=
action $
  "(function(){var x = qi('" ++ elem ++
  "'); if (x) x.style.display = '" ++ status ++ "';})();"

def show' (elem : String) := display elem "block"
def hide' (elem : String) := display elem "none"
