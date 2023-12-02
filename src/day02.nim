import
  sugar,
  std/nre,
  std/strutils,
  std/sequtils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  GameSet = tuple[red, green, blue: int]
  Game = tuple[id: int, sets: seq[GameSet]]

let
  redRe = re"(\d+) red"
  greenRe = re"(\d+) green"
  blueRe = re"(\d+) blue"

proc parseSet(set: string): GameSet =
  result.red = set.find(redRe).map(m => m.captures[0].parseInt).get(0)
  result.green = set.find(greenRe).map(m => m.captures[0].parseInt).get(0)
  result.blue = set.find(blueRe).map(m => m.captures[0].parseInt).get(0)

proc parseGame(line: string): Game =
  let
    parts = line.split(": ")
    gameId = parts[0]
    setList = parts[1]

  result.id = gameId.replace("Game ", "").parseInt
  result.sets = setList.split("; ").map(parseSet)

proc partOne(input: seq[Game]): string =
  var sum = 0
  for game in input:
    var possible = true
    for set in game.sets:
      if set.red > 12 or set.green > 13 or set.blue > 14:
        possible = false
        break
    if possible:
      sum += game.id
  $sum

proc partTwo(input: seq[Game]): string =
  var sum = 0
  for game in input:
    var minRed, minGreen, minBlue = 0
    for set in game.sets:
      if set.red > minRed:
        minRed = set.red
      if set.green > minGreen:
        minGreen = set.green
      if set.blue > minBlue:
        minBlue = set.blue
    sum += minRed * minGreen * minBlue
  $sum

when isMainModule:
  echo "### DAY 02 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(parseGame)

