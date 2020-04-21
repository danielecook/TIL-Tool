# TIL (Today I Learned)
# Author: Daniel E. Cook
# danielecook.com
import algorithm
import os
import strformat
import strutils
import colorize
import argparse
import osproc
import tables
import nre
import times
from posix import signal, SIG_PIPE, SIG_IGN
signal(SIG_PIPE, SIG_IGN)

const VERSION = "0.0.1"
const TIL_DIR = getHomeDir().joinPath(".til")
const README_PATH = getHomeDir().joinPath(".til").joinPath("README.md")
const MAX_LEN = 20 # Maximum topic and title length

type 
    til_object = ref object
        topic: string
        title: string
        fname: string
        basename: string
        description: string
        date: times.Time

proc `$`(til: til_object) =
    echo fmt"""[{til.title}] {til.description} {til.date.format("yyyy-MM-dd")}"""


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

proc check_input(check_str: string): bool = 
    if check_str.len > MAX_LEN:
        error_msg fmt"'{check_str}' can only be {MAX_LEN} characters long"
    if check_str.is_safe() == false:
        error_msg fmt"'{check_str}' must match '^[0-9a-zA-Z-\._]+$'"
    return true

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
        comm = fmt"subl -w {fname}:1:3"
    elif editor == "nano":
        # nano
        check_comm("nano")
        comm = fmt"nano +0,2 {fname}"
    elif editor.startsWith("vi"):
        # vim / vi
        check_comm(editor)
        comm = fmt"{editor} {fname} '+call cursor(0,2)'"
    elif editor == "atom":
        # atom
        check_comm(editor)
        comm = fmt"atom {fname}:0:2"
    elif editor == "emacs":
        # emacs
        check_comm(editor)
        comm = fmt"emacs +0:2 {fname}"
    else:
        check_comm(editor)
        comm = fmt"{editor} {fname}"
    return comm

proc get_description(fname: string): string = 
    # Extracts the description from the title
    var f: File
    var line: string
    try:
        discard open(f, fname, fmRead)
        line = f.readLine()
    finally:
        close(f)
    if line.startsWith("#"):
        return line.strip(chars = {'#', ' '})
    else:
        return ""

proc list_tils(): Table[string, seq[til_object]] =
    var all_tils = initTable[string, newSeq[til_object]()]()
    for full_path in walkDirs(TIL_DIR.joinPath("/*")):
        let topic = full_path.lastPathPart()
        for til_fname in walkFiles(TIL_DIR.joinPath(topic & "/*")):
            if topic in all_tils == false:
                all_tils[topic] = @[]
            var til = til_object(fname: til_fname,
                           topic: topic,
                           title: til_fname.lastPathPart()[0..^4],
                           description: get_description(til_fname),
                           date: til_fname.getCreationTime())
            all_tils[topic].add(til)
    return all_tils

proc case_insensitive_sort(x, y: string): int =
  if x.to_lower() < y.to_lower(): -1
  elif x.to_lower() == y.to_lower(): 0
  else: 1

proc build_readme() =
    var til_set = list_tils()

    # Count number of tils
    var til_count = 0
    for topic_tils in til_set.values():
        til_count += topic_tils.len

    var f: File
    var topic_set = new_seq[string]()
    if open(f, README_PATH, fmWrite):
        try:
            f.writeLine("# TIL" & '\n' & "> Today I Learned" & '\n')
            f.writeLine(fmt"* TILs: {til_count}")
            f.writeLine(fmt"* Topics: {til_set.len()}" & '\n')
            for key in til_set.keys():
                topic_set.add(key)
            topic_set.sort(case_insensitive_sort)
            for topic in topic_set:
                f.writeLine(fmt"## {topic}" & '\n')
                for til in til_set[topic]:
                    f.writeLine(fmt"""* [`{til.title}`]({til.topic}/{til.title}.md) {til.description} ({til.date.format("yyyy-MM-dd")})""")
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
                topic, title, fpath: string
            (topic, title) = opts.fname.split("/")

            # Strip .md from end if it exists
            if title.to_lower().endsWith(".md"):
                title = title[0..^4]

            fpath = TIL_DIR.joinPath(topic).joinPath(fmt"{title}.md")
            if topic.check_input() and title.check_input():
                discard existsOrCreateDir(TIL_DIR.joinPath(topic))
                if fpath.fileExists() == false:
                    var f: File
                    if open(f, fpath, fmWrite):
                        try:
                            f.writeLine(fmt"# description" & '\n' & '\n')
                        finally:
                            close(f)
                let result = execCmd(editor_cmd(fpath))
                build_readme()
                if result == 0:
                    success_msg(fmt"Successfully added {topic}/{title}")

    command("ls"):
        arg("query", nargs = -1, help="Term to match on")
        run:
            var til_set = list_tils()
            var output: bool
            echo fmt"""{("Group".fgGreen & "/title"):<50}{"description":<40}{"date":<20}""".fgGreen
            echo "-".repeat(100)
            for group, tils in til_set:
                for til in tils:
                    let gt = group.fgGreen & "/" & til.title
                    if opts.query.len() > 0:
                        output = (group == opts.query[0] or opts.query[0] in til.title)
                    else:
                        output = true    
                    if output:
                        echo fmt"""{gt:<50}{til.description:<40}{til.date.format("yyyy-MM-dd"):<20}"""

    command("push"):
        help("Push TILs to a repo")
        option("-r", "--remote", help="Setup remote and configure as default")
        run:
            build_readme()
            # Add files and commit
            if opts.remote != "":
                let (outp, err) = execCmdEx(&"""cd ~/.til && \
                                             git remote remove origin || true && \
                                             git remote add origin "{opts.remote}" && \
                                             git remote set-url --push origin "{opts.remote}" && \
                                             git push --set-upstream origin master""")
                if err != 0:
                    error_msg &"[{err}] {outp.strip()}"
            msg "Adding TILs, commiting, and pushing"
            discard execCmd(fmt"cd {TIL_DIR} && git add . && git commit -m 'Update on {times.getDateStr()}' && git push")

# Initialize
discard existsOrCreateDir(TIL_DIR)
if dirExists(TIL_DIR.joinPath(".git")) == false:
    let git_init_result = execCmd(fmt"git init {TIL_DIR}")
    if git_init_result != 0:
        error_msg "Unable to initalize git repository. Is git installed?"

if commandLineParams().len() == 0:
    p.run(@["-h"])
else:
    try:
        p.run(commandLineParams())
    except UsageError as E:
        error_msg(E.msg)
