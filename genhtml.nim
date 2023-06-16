import std/parsecfg
import std/strutils
import std/os
import std/sugar
import std/parseopt

let 
  notDir   = "Invalid directory or not found!"
  notValid = "Invalid option"
  empty    = "Expected an argument"

var 
  pathToDir: string 
  snC      : string 
  docC     : string
  headC    : string
  cusC     : string
  all      : string
  snEC     : string
  docEC    : string
  tab      : int    = 0
  

proc die(s:string) =
  echo "ERROR: ", s
  quit(1)

proc fmthelp(opt: string, desc: string) =
  echo opt
  echo "            ", desc

proc help() =
  let name = lastPathPart(getAppFilename())
  echo name, " - a dumb HTML generator from text file, mainly for API documentation"
  echo "Usage: ", name, " [options]"
  var orderHelp:string = "            Specify the order of .html files to be generated\n"
  orderHelp &= "Default order is head.html custom.html sidenav.html doc.html\n"
  orderHelp &= "sidenav.html and doc.html are auto-generated, head.html and custom.html\n"
  orderHelp &= "are skipped if they do not exist\n"
  echo "\nOption:"
  fmthelp("-h | --help", "Print this message")
  fmthelp("-d | --dir=[dir]", "Path to directory which contains the files")
  echo "style.css can be used to apply style for HTML file(s).There is an example\n"
  echo "For more details, read EXPLAINATION.md" 
  quit(0)

proc checkExt(f: string): bool =
  var 
    basename: string = lastPathPart(f)
    rightExt: bool   = false

  for ext in split(basename, "."):
    if (ext == "ai"): # stand for API information
      rightExt = true
  
  return rightExt

proc Begin(element: string, file: File) =
  var e: string

  for i in 0 ..< tab:
    e &= "  "
  e &= "<" & element & ">\n"
  write(file, e)
  tab += 1

proc End(element: string, file: File) =
  var e: string

  if tab > 0:
    tab -= 1
  for i in 0 ..< tab:
    e &= "  "
  e &= "</" & element & ">\n"
  write(file, e)

proc WriteComplete(t: string, con: string, file: File) =
  if con != "":
    var 
      element: string
      tabAll: string
      sentence: string
      useDot : string
      title: string
    
    case t
    of "name":
      element = "h3 id=\"" & con & "\""
    of "namenav":
      element = "a href=\"#" & con & "\""
    of "desc":
      useDot = "."
      element = "p"
      title = "<b>Description: </b>"
    of "warn":
      useDot = "."
      element = "p"
      title = "<b>Warning: </b>"
    of "note":
      useDot = "."
      element = "p"
      title = "<i>Note: </i>"
    of "where":
      element = "p"
      title = "<b>Where: </b>"
    of "syntax":
      element = "p style=\"background-color: #1f1f1f; color: #ffffff\""
    else:
      die("Unknown type")

    Begin(element, file)
    # Idk what I should use to split the sentences, so Ill use '.'
    
    for p in 0 ..< tab:
      tabAll &= "  "

    for p in split(con, "."):
      sentence &= tabAll & title & p & useDot & "\n"

    write(file, sentence)
 
    case t
    of "name":
      element = "h3"
    of "namenav":
      element = "a"
    else:
      element = "p"

    End(element, file)

proc line(con: string, file: File) =
  var sentence: string
  for i in 0 ..< tab:
    sentence &= "  "
  sentence &= con & "\n"
  write(file, sentence)

var param = initOptParser()
while true:
  param.next()
  case param.kind
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    case param.key
    of "d", "dir":
      if (param.val == ""):
        die(empty)
      pathToDir = param.val
    of "h", "help":
      help()
    of "g", "generate-template":
      continue
    else:
      die(notValid)
  of cmdArgument:
    die(notValid)

if (pathToDir == ""):
  pathToDir = "."
elif (pathToDir.dirExists() == false or pathToDir.fileExists() == true):
  die(notDir)

let finalP = open(pathToDir & "/final.html", fmReadWrite)

let head = pathToDir & "/head.html"
let cus  = pathToDir & "/custom.html"

let doc  = pathToDir & "/doc.html"
var docP = open(doc, fmReadWrite)

let sn   = pathToDir & "/sidenav.html"
var snP  = open(sn, fmReadWrite)

let sne  = pathToDir & "/sidenav-extend.html"
if sne.fileExists() == true:
  let snE  = open(sne, fmRead)
  snEC = readAll(snE)
  close(snE)

let doce = pathToDir & "/doc-extend.html"
if doce.fileExists() == true:
  let docE = open(doce, fmRead)
  docEC = readAll(docE)
  close(docE)

let path = pathToDir & "/*"
let files = collect(newSeq):
  for file in walkFiles(path):
    file

tab = 3
Begin("div class=\"sidenav\"", snP)
tab = 3
Begin("div class=\"doc\"", docP)

if snEC != "":
  write(snP, snEC)

if docEC != "":
  write(docP, docEC)

for f in files:
      
  let rightExt = checkExt(f)
  if (rightExt == false):
    continue 
  
  # name will be <h3>name</h3>
  # where,desc,warn,note will be <p><b>Title</b>where</p>
  # syntax will be <p style="background-color:#1f1f1f;color=#ffffff"></p>
  let dict     = loadConfig(f);
  let name     = dict.getSectionValue("", "name")
  let where    = dict.getSectionValue("", "where")
  let desc     = dict.getSectionValue("", "desc")
  let syntax   = dict.getSectionValue("", "syntax")
  let warn     = dict.getSectionValue("", "warn")
  let note     = dict.getSectionValue("", "note")

  WriteComplete("namenav", name, snP)
  WriteComplete("name", name, docP)
  WriteComplete("where", where, docP)
  WriteComplete("desc", desc, docP)
  WriteComplete("syntax", syntax, docP)
  WriteComplete("warn", warn, docP)
  WriteComplete("note", note, docP)

tab = 4
End("div", snP)
tab = 4
End("div", docP)

if head.fileExists() == true:
  let headP = open(head, fmRead)
  headC = readAll(headP)
  headP.close()

if cus.fileExists() == true:
  let cusP = open(cus, fmRead)
  cusC = readAll(cusP)
  cusP.close()

snP.close()
snP = open(sn, fmRead)
snC = readAll(snP)

docP.close()
docP = open(doc, fmRead)
docC = readAll(docP)

tab = 0
Begin("!DOCTYPE html>\n<html", finalP)
if headC != "":
  write(finalP, headC)
else:
  Begin("head", finalP)
  line("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">", finalP)
  line("<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">", finalP)
  End("head", finalP)
Begin("body", finalP)
all = cusC & "\n" & snC & "\n" & docC & "\n"
write(finalP, all)
End("body", finalP)
End("html", finalP)
