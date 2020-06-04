import NITRO.Tags

variable {α : Type}

def div := @Elem.tag α "div"
def title := @Elem.tag α "title" []

def idAttr := Attr.str "id"
def classAttr := Attr.list "class"

def br := @Elem.unpaired α "br" []
def hr := @Elem.unpaired α "hr" []
