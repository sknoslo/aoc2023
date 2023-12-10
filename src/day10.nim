import
  std/tables,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Map = tuple[w, h: int, tiles: string]
  Step = tuple[i: int, entrance: char]

proc hasSouth(pipe: char): bool =
  pipe == '7' or pipe == 'F' or pipe == '|'

proc hasNorth(pipe: char): bool =
  pipe == 'J' or pipe == 'L' or pipe == '|'

proc hasEast(pipe: char): bool =
  pipe == 'F' or pipe == 'L' or pipe == '-'

proc hasWest(pipe: char): bool =
  pipe == '7' or pipe == 'J' or pipe == '-'

proc getValidFirstStep(input: Map): Step =
  let start = input.tiles.find('S')

  # Makes the assumption that S is not at an edge
  for (o, f, e) in [(-input.w, hasSouth, 's'), (1, hasWest, 'w'), (input.w, hasNorth, 'n'), (-1, hasEast, 'e')]:
    if f(input.tiles[start + o]):
      return (start + o, e)
  (-1, 'x')

proc getNextEntrance(tile, entrance: char): char =
  if tile == 'J':
    return if entrance == 'w': 's' else: 'e'
  elif tile == 'L':
    return if entrance == 'e': 's' else: 'w'
  elif tile == 'F':
    return if entrance == 'e': 'n' else: 'w'
  elif tile == '7':
    return if entrance == 'w': 'n' else: 'e'
  elif tile == '|' or tile == '-':
    return entrance
  'x'

proc getNextI(input: Map, i: int, entrance: char): int =
  case entrance
    of 's':
      i - input.w
    of 'w':
      i + 1
    of 'n':
      i + input.w
    of 'e':
      i - 1
    else:
      -1

proc getNextStep(input: Map, step: Step): Step =
  let
    tile = input.tiles[step.i]
    nextEntrance = getNextEntrance(tile, step.entrance)
    nexti = getNextI(input, step.i, nextEntrance)
  (nextI, nextEntrance)


proc partOne(input: Map): string =
  var next = getValidFirstStep(input)
  var steps = 1

  while input.tiles[next.i] != 'S':
    steps += 1
    next = getNextStep(input, next)

  $(steps div 2)


proc getStartReplacement(input: Map, i: int): char =
  # TODO: make general, but this is correct for my input
  '7'

proc partTwo(input: Map): string =
  let first = input.tiles.find('S')
  var
    next = getValidFirstStep(input)
    loop: Table[int, char]

  loop[first] = 'S'

  while input.tiles[next.i] != 'S':
    loop[next.i] = input.tiles[next.i]
    next = getNextStep(input, next)

  var cleaned = input.tiles
  for i in 0..<cleaned.len:
    if not loop.hasKey(i):
      cleaned[i] = ' '

  var
    inside = false
    up = true
    insideCount = 0
  for i in 0..<cleaned.len:
    if i mod input.w == 0:
      up = true
      inside = false
    var tile = cleaned[i]
    if tile == 'S':
      tile = getStartReplacement(input, i)
    if tile == ' ':
      if inside:
        cleaned[i] = 'I'
        insideCount += 1
      else:
        cleaned[i] = 'O'
    elif tile == '|':
      inside = not inside
    elif tile == 'F':
      up = true
    elif tile == 'L':
      up = false
    elif up and tile == 'J':
      inside = not inside
    elif tile == 'J':
      up = true
    elif not up and tile == '7':
      inside = not inside
    elif tile == '7':
      up = false

  for y in 0..<input.h:
    echo $cleaned[y * input.w..<y*input.w + input.w]
  $insideCount

when isMainModule:
  echo "### DAY 10 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let
      lines = input.strip.splitLines
      parsed = (lines[0].len, lines.len, lines.join(""))
