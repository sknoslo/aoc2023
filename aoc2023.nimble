# Package

version       = "0.1.0"
author        = "Steffen Olson"
description   = "AOC 2023 Solutions"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
installExt    = @["nim"]
bin           = @[
  "day01",
  "day02",
  "day03",
  "day04"
]


# Dependencies

requires "nim >= 2.0.0"
