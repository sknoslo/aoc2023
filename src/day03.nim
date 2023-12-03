import
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Schematics = tuple[w, h: int, cells: string]


proc partOne(input: Schematics): string =
  var sum = 0

  proc expand(x, y: int): int =
    var s, e = x
    while s > 0 and input.cells[y * input.w + s - 1] in Digits:
      s -= 1
    while e < input.w - 1 and input.cells[y * input.w + e + 1] in Digits:
      e += 1
    let
      si = y * input.w + s
      ei = y * input.w + e
    parseInt(input.cells[si..ei])

  proc addLeft(x, y: int): int =
    if x > 0 and input.cells[y * input.w + x - 1] in Digits:
      result = expand(x-1, y)

  proc addRight(x, y: int): int =
    if x < input.w - 1 and input.cells[y * input.w + x + 1] in Digits:
      result = expand(x+1, y)

  proc addTop(x, y: int): int =
    if y > 0:
      if input.cells[(y - 1) * input.w + x] in Digits:
        result = expand(x, y-1)
      else:
        result = addLeft(x, y-1) + addRight(x, y-1)

  proc addBottom(x, y: int): int =
    if y < input.h - 1:
      if input.cells[(y + 1) * input.w + x] in Digits:
        result = expand(x, y+1)
      else:
        result = addLeft(x, y+1) + addRight(x, y+1)

  for i in 0..<input.cells.len:
    let cell = input.cells[i]
    if cell != '.' and cell notin Digits:
      let
        x = i mod input.h
        y = i div input.h

      sum += addLeft(x, y)
      sum += addRight(x, y)
      sum += addTop(x, y)
      sum += addBottom(x, y)
  $sum

proc partTwo(input: Schematics): string =
  var sum = 0

  proc expand(x, y: int): int =
    var s, e = x
    while s > 0 and input.cells[y * input.w + s - 1] in Digits:
      s -= 1
    while e < input.w - 1 and input.cells[y * input.w + e + 1] in Digits:
      e += 1
    let
      si = y * input.w + s
      ei = y * input.w + e
    parseInt(input.cells[si..ei])

  proc addLeft(x, y: int, numCount: var int): int =
    result = 1
    if x > 0 and input.cells[y * input.w + x - 1] in Digits:
      result = expand(x-1, y)
      numCount += 1

  proc addRight(x, y: int, numCount: var int): int =
    result = 1
    if x < input.w - 1 and input.cells[y * input.w + x + 1] in Digits:
      result = expand(x+1, y)
      numCount += 1

  proc addTop(x, y: int, numCount: var int): int =
    result = 1
    if y > 0:
      if input.cells[(y - 1) * input.w + x] in Digits:
        result = expand(x, y-1)
        numCount += 1
      else:
        result = addLeft(x, y-1, numCount) * addRight(x, y-1, numCount)

  proc addBottom(x, y: int, numCount: var int): int =
    result = 1
    if y < input.h - 1:
      if input.cells[(y + 1) * input.w + x] in Digits:
        result = expand(x, y+1)
        numCount += 1
      else:
        result = addLeft(x, y+1, numCount) * addRight(x, y+1, numCount)

  for i in 0..<input.cells.len:
    let cell = input.cells[i]
    if cell == '*':
      let
        x = i mod input.h
        y = i div input.h

      var
        numCount = 0
        gearSum = 1

      gearSum *= addLeft(x, y, numCount)
      gearSum *= addRight(x, y, numCount)
      gearSum *= addTop(x, y, numCount)
      gearSum *= addBottom(x, y, numCount)
      if numCount == 2:
        sum += gearSum
  $sum

when isMainModule:
  echo "### DAY 03 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let
      lines = input.strip.splitLines
      h = lines.len
      w = lines[0].len
      cells = input.replace("\n", "")
      parsed = (w, h, cells)
