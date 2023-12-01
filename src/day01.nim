import
  sugar,
  std/re,
  std/strutils,
  std/sequtils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

proc partOne(input: seq[string]): string =
  var sum = 0
  for line in input:
    let matches = line.findAll(re"\d")
    sum += parseInt(matches[0]&matches[^1])

  $sum

proc partTwo(input: seq[string]): string =
  var sum = 0
  for line in input:
    var matches: seq[string]

    # have to go one char at a time, because numbers can overlap like twone... and I don't think std/re supports lookahead
    # or I don't know how to use it properly
    for i in 0..<line.len:
      var match: array[1, string]
      let ismatch = line[i..^1].match(re"^(\d|one|two|three|four|five|six|seven|eight|nine)", match)
      if ismatch:
        matches.add(match[0])
    let replaced = matches.map(match => match.multiReplace(("one", "1"), ("two", "2"), ("three", "3"), ("four", "4"), ("five", "5"), ("six", "6"), ("seven", "7"), ("eight", "8"), ("nine", "9")))

    sum += parseInt(replaced[0]&replaced[^1])

  $sum

when isMainModule:
  echo "### DAY 00 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines
