import os
import strformat
import strutils
import colorize
import argparse
import osproc
import tables
import nre
from posix import signal, SIG_PIPE, SIG_IGN
signal(SIG_PIPE, SIG_IGN)

const VERSION = "0.0.1"
const TIL_DIR = getHomeDir().joinPath(".til")
const README_PATH = getHomeDir().joinPath(".til").joinPath("README.md")

# Init
discard existsOrCreateDir(TIL_DIR)

# Messages
proc msg(msg: string) =
    stderr.write_line fmt"{msg}".fgBlue

proc error_msg(msg: string) =
    stderr.write_line fmt"Error {msg}".fgRed
    quit(1)

proc success_msg(msg: string) =
    stderr.write_line fmt"{msg}".fgGreen

proc is_safe(check_str: string): bool =
    return check_str.match(re"^[0-9a-zA-Z-\._]+$").isSome

proc check_comm(s: string) =
    # Checks that a command exists
    if findExe(s) == "":
        error_msg fmt"Cannot find {s}, is it installed?"

proc editor_cmd(fname: string): string = 
    # Returns the users preferred editor
    var editor = os.getEnv("EDITOR", "")
    var comm: string
    # Setup editor configuration
    if editor.startsWith("subl"):
        # sublime
        check_comm("subl")
        comm = fmt"subl -w {fname}:3"
    elif editor == "nano":
        # nano
        check_comm("nano")
        comm = fmt"nano +3,0 {fname}"
    elif editor.startsWith("vi"):
        # vim / vi
        check_comm(editor)
        comm = fmt"{editor} {fname} '+call cursor(3,0)'"
    elif editor == "atom":
        # atom
        check_comm(editor)
        comm = fmt"atom {fname}:3"
    elif editor == "emacs":
        # emacs
        check_comm(editor)
        comm = fmt"emacs +3:0 {fname}"
    else:
        check_comm(editor)
        comm = fmt"{editor} {fname}"
    return comm

proc list_tils(): Table[string, seq[string]] =
    var all_tils = initTable[string, newSeq[string]()]()
    for full_path in walkDirs(TIL_DIR.joinPath("/*")):
        let topic = full_path.lastPathPart()
        for til_fname in walkFiles(TIL_DIR.joinPath(topic & "/*")):
            let til = til_fname.lastPathPart()[0..^4]
            if topic in all_tils == false:
                all_tils[topic] = @[]
            all_tils[topic].add(til)
    return all_tils
        
proc build_readme() =
    var til_set = list_tils()

    # Count number of tils
    var til_count = 0
    for topic_tils in til_set.values():
        til_count += topic_tils.len

    var f: File
    if open(f, README_PATH, fmWrite):
        try:
            f.writeLine("# TIL" & '\n')
            f.writeLine(fmt"n TILs: {til_count}")
            f.writeLine(fmt"n Topics: {til_set.len()}")
            for topic in til_set.keys():
                f.writeLine(fmt"## {topic}" & '\n')
                for til in til_set[topic]:
                    f.writeLine(fmt"* [{til}]({topic}/{til}.md) - DESCRIPTION")
                f.writeLine("")
        finally:
            close(f)


var p = newParser("til"):
    help(fmt"Today I Learned (Version {VERSION})")
    command("open"):
        help("Create or edit a new TIL")
        arg("fname", nargs = 1, help="Filename in the format topic/title (e.g. R/create_matrix")
        run:
            if "/" in opts.fname == false:
                error_msg("Must specify TIL as topic/title")
            
            var 
                folder_name, title, fpath: string
            (folder_name, title) = opts.fname.split("/")

            # Strip .md from end if it exists
            if title.to_lower().endsWith(".md"):
                title = title[0..^4]

            fpath = TIL_DIR.joinPath(folder_name).joinPath(fmt"{title}.md")
            if folder_name.is_safe():
                discard existsOrCreateDir(TIL_DIR.joinPath(folder_name))
                if fpath.fileExists() == false:
                    var f: File
                    if open(f, fpath, fmWrite):
                        try:
                            f.writeLine(fmt"# {title}" & '\n' & '\n')
                        finally:
                            close(f)
                let result = execCmd(editor_cmd(fpath))
                if result == 0:
                    success_msg(fmt"Successfully added {folder_name}/{title}")

    command("push"):
        help("Push TILs to a repo")
        run:
            echo "Pushing"

echo list_tils()
build_readme()

if commandLineParams().len() == 0:
    p.run(@["-h"])
else:
    try:
        p.run(commandLineParams())
    except UsageError as E:
        error_msg(E.msg)
