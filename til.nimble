# Package

version       = "0.0.2"
author        = "Daniel E. Cook"
description   = "seq-collection: Sequence data utilities"
license       = "MIT"

# Dependencies

requires "colorize"
requires "argparse"

bin = @["til"]
skipDirs = @["test"]

task test, "run tests":
  exec "bash ./scripts/functional-tests.sh"
  #exec "nim c --threads:on -d:release --lineDir:on --debuginfo -r tests/all"