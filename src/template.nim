import
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

proc partOne(input: string): string =
  "INCOMPLETE"

proc partTwo(input: string): string =
  "INCOMPLETE"

when isMainModule:
  echo "### DAY 00 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    # do any prelim parsing or setup here
    let parsed = input.strip # strip is nice for basic line splits but makes real parsers harder
