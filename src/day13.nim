import
  sugar,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

proc isVerticallyMirroredAbout(pattern: seq[string], x: int): bool =
  var
    l = x - 1
    r = x

  while l >= 0 and r < pattern[0].len:
    for i in 0..<pattern.len:
      if pattern[i][l] != pattern[i][r]:
        return false
    l -= 1
    r += 1
  true

proc isHorizontallyMirroredAbout(pattern: seq[string], y: int): bool =
  var
    t = y - 1
    b = y

  while t >= 0 and b < pattern.len:
    if pattern[t] != pattern[b]:
      return false
    t -= 1
    b += 1
  true

proc partOne(patterns: seq[seq[string]]): string =
  var sum = 0
  
  for pattern in patterns:
    block patternCheck:
      for x in 1..<pattern[0].len:
        if pattern.isVerticallyMirroredAbout(x):
          sum += x
          break patternCheck
      for y in 1..<pattern.len:
        if pattern.isHorizontallyMirroredAbout(y):
          sum += y * 100
          break patternCheck

  $sum

proc isAlmostVerticallyMirroredAbout(pattern: seq[string], x: int): bool =
  var
    l = x - 1
    r = x
    hasSmudge = false

  while l >= 0 and r < pattern[0].len:
    for i in 0..<pattern.len:
      if pattern[i][l] != pattern[i][r]:
        if hasSmudge:
          return false
        hasSmudge = true
    l -= 1
    r += 1
  hasSmudge

proc isAlmostHorizontallyMirroredAbout(pattern: seq[string], y: int): bool =
  var
    t = y - 1
    b = y
    hasSmudge = false

  while t >= 0 and b < pattern.len:
    for i in 0..<pattern[0].len:
      if pattern[t][i] != pattern[b][i]:
        if hasSmudge:
          return false
        hasSmudge = true
    t -= 1
    b += 1
  hasSmudge

proc partTwo(patterns: seq[seq[string]]): string =
  var sum = 0
  
  for pattern in patterns:
    block patternCheck:
      for x in 1..<pattern[0].len:
        if pattern.isAlmostVerticallyMirroredAbout(x):
          sum += x
          break patternCheck
      for y in 1..<pattern.len:
        if pattern.isAlmostHorizontallyMirroredAbout(y):
          sum += y * 100
          break patternCheck

  $sum

when isMainModule:
  echo "### DAY 13 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.split("\n\n").map(x => x.splitLines)
