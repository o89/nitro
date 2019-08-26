import network.n2o.internal data.bert
import web.nitro.elements
open network.n2o.internal data.bert

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

def update (target : String) (elem : Elem) : Result :=
action $ "qi('" ++ target ++ "').outerHTML='" ++ render elem ++ "';"

def updateText (target text : String) : Result :=
action $ "qi('" ++ target ++ "').innerText='" ++ text ++ "';"

def insertTagTop (tag target : String) (elem : Elem) : Result :=
action $
  "qi('" ++ target ++ "').insertBefore(" ++
  "(function(){ var div = qn('" ++ tag ++ "'); div.innerHTML = '" ++
  render elem ++ "'; return div.firstChild; })()," ++
  "qi('" ++ target ++ "').firstChild);"

def insertTagBottom (tag target : String) (elem : Elem) : Result :=
action $
  "(function(){ var div = qn('" ++ tag ++
  "'); div.innerHTML = '" ++ render elem ++
  "';qi('" ++ target ++ "').appendChild(div.firstChild); })();"

def insertTop := insertTagTop "div"
def insertBottom := insertTagBottom "div"

def insertAdjacent (position target : String) (elem : Elem) :=
action $
  "qi('" ++ target ++ "').insertAdjacentHTML('" ++
  position ++ "', '" ++ render elem ++ "');"

def insertBefore := insertAdjacent "beforebegin"
def insertAfter := insertAdjacent "afterend"

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
