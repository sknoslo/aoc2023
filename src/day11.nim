import
  std/sets,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Coords = tuple[x, y: int]
  Universe = tuple[w, h: int, tiles: string]

proc getEmptyRowsAndCols(input: Universe): tuple[rows, cols: HashSet[int]] =
  var
    rows = toHashSet((0..<input.h).toSeq)
    cols = toHashSet((0..<input.w).toSeq)

  for y in 0..<input.h:
    for x in 0..<input.w:
      if input.tiles[y * input.w + x] == '#':
        rows.excl(y)
        cols.excl(x)

  (rows, cols)

proc partOne(input: Universe): string =
  var
    galaxies = newSeqOfCap[Coords](input.tiles.count('#'))

  let
    empty = getEmptyRowsAndCols(input)

  var sy = 0
  for y in 0..<input.h:
    if y in empty.rows:
      sy += 2
      continue
    var sx = 0
    for x in 0..<input.w:
      if x in empty.cols:
        sx += 2
        continue
      if input.tiles[y * input.w + x] == '#':
        galaxies.add((sx, sy))
      sx += 1
    sy += 1

  var sum = 0

  for a in 0..<(galaxies.len - 1):
    let l = galaxies[a]
    for b in (a+1)..<galaxies.len:
      let r = galaxies[b]
      sum += abs(r.x - l.x) + abs(r.y - l.y)

  $sum

proc partTwo(input: Universe): string =
  var
    galaxies = newSeqOfCap[Coords](input.tiles.count('#'))

  let
    empty = getEmptyRowsAndCols(input)

  var sy = 0
  for y in 0..<input.h:
    if y in empty.rows:
      sy += 1000000
      continue
    var sx = 0
    for x in 0..<input.w:
      if x in empty.cols:
        sx += 1000000
        continue
      if input.tiles[y * input.w + x] == '#':
        galaxies.add((sx, sy))
      sx += 1
    sy += 1

  var sum = 0

  for a in 0..<(galaxies.len - 1):
    let l = galaxies[a]
    for b in (a+1)..<galaxies.len:
      let r = galaxies[b]
      sum += abs(r.x - l.x) + abs(r.y - l.y)

  $sum

when isMainModule:
  echo "### DAY 11 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let
      lines = input.strip.splitLines
      parsed = (lines[0].len, lines.len, lines.join(""))
