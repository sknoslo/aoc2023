import
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

iterator rev(a, b: int): int =
  var next = a
  while next >= b:
    yield next
    next -= 1

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

proc tiltEast(platform: seq[string]): seq[string] =
  var nextPlatform = platform

  for x in rev(nextPlatform[0].len - 1, 0):
    for y in 0..<nextPlatform.len:
      if nextPlatform[y][x] == 'O':
        var landed = false
        for dx in x+1..<nextPlatform[0].len:
          if nextPlatform[y][dx] != '.':
            nextPlatform[y][x] = '.'
            nextPlatform[y][dx-1] = 'O'
            landed = true
            break
        if not landed:
          nextPlatform[y][x] = '.'
          nextPlatform[y][^1] = 'O'

  nextPlatform

proc tiltSouth(platform: seq[string]): seq[string] =
  var nextPlatform = platform

  for y in rev(platform.len - 1, 0):
    let row = nextPlatform[y]

    for x in 0..<row.len:
      if row[x] == 'O':
        var landed = false
        for dy in y+1..<nextPlatform.len:
          if nextPlatform[dy][x] != '.':
            nextPlatform[y][x] = '.'
            nextPlatform[dy-1][x] = 'O'
            landed = true
            break
        if not landed:
          nextPlatform[y][x] = '.'
          nextPlatform[^1][x] = 'O'

  nextPlatform

proc tiltWest(platform: seq[string]): seq[string] =
  var nextPlatform = platform

  for x in 0..<nextPlatform[0].len:
    for y in 0..<nextPlatform.len:
      if nextPlatform[y][x] == 'O':
        var landed = false
        for dx in 1..x:
          if nextPlatform[y][x-dx] != '.':
            nextPlatform[y][x] = '.'
            nextPlatform[y][x-dx+1] = 'O'
            landed = true
            break
        if not landed:
          nextPlatform[y][x] = '.'
          nextPlatform[y][0] = 'O'

  nextPlatform

proc spinCycle(platform: seq[string]): seq[string] =
  platform.tiltNorth.tiltWest.tiltSouth.tiltEast

proc partOne(platform: seq[string]): string =
  var sum = 0
  for (y, row) in platform.tiltNorth.pairs:
    let rocks = row.count('O')
    sum += rocks * (platform.len - y)

  $sum

proc sum(platform: seq[string]): int =
  for (y, row) in platform.pairs:
    let rocks = row.count('O')
    result += rocks * (platform.len - y)

proc partTwo(platform: seq[string]): string =
  let
    maxCycle = 100
    targetCycles = 1000000000
  var
    next = platform
    startDetection = 200
    captureSecond = false
    firstCycle = newSeqOfCap[int](maxCycle)
    secondCycle = newSeqOfCap[int](maxCycle)

  # surely there is a pre existing cycle detection algo that I could learn...
  for i in 1..targetCycles:
    next = next.spinCycle
    if i >= startDetection:
      let nextSum = next.sum
      if captureSecond:
        if secondCycle.len < firstCycle.len:
          secondCycle.add(nextSum)
        if secondCycle.len == firstCycle.len:
          # crash if they don't equal, would be better to auto-tweak the params and keep going
          doAssert secondCycle == firstCycle, "Cycles did not match, tweak params and try again"
          break
      elif firstCycle.len > 0 and nextSum == firstCycle[0]:
        captureSecond = true
        secondCycle.add(nextSum)
      else:
        if firstCycle.len > maxCycle:
          firstCycle = newSeqOfCap[int](maxCycle)
          startDetection = i + 1
        else:
          firstCycle.add(nextSum)

  $firstCycle[(targetCycles - startDetection) mod firstCycle.len]

when isMainModule:
  echo "### DAY 14 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines
