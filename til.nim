import os
import strformat
import argparse
from posix import signal, SIG_PIPE, SIG_IGN
signal(SIG_PIPE, SIG_IGN)

const VERSION = "0.0.1"

var p = newParser("til"):
    help(fmt"Today I Learned (Version {VERSION})")
    command("open"):
        help("Create or edit a new TIL")
        arg("fname", nargs = -1, help="Filename in the format topic/title (e.g. R/create_matrix")
        run:
            echo "GREAT"


p.run(commandLineParams())
