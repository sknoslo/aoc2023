import
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

proc tiltNorth(platform: seq[string]): seq[string] =
  var nextPlatform = platform

  for y in 0..<platform.len:
    let row = nextPlatform[y]

    for x in 0..<row.len:
      if row[x] == 'O':
        var landed = false
        for dy in 1..y:
          if nextPlatform[y-dy][x] != '.':
            nextPlatform[y][x] = '.'
            nextPlatform[y-dy+1][x] = 'O'
            landed = true
            break
        if not landed:
          nextPlatform[y][x] = '.'
          nextPlatform[0][x] = 'O'

  nextPlatform

proc partOne(platform: seq[string]): string =
  var sum = 0
  for (y, row) in platform.tiltNorth.pairs:
    let rocks = row.count('O')
    sum += rocks * (platform.len - y)

  $sum

proc partTwo(platform: seq[string]): string =
  "INCOMPLETE"

when isMainModule:
  echo "### DAY 14 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines
