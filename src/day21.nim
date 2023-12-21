import
  std/math,
  std/sets,
  std/deques,
  std/tables,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec2 = tuple[x, y: int]
  State = tuple[loc: Vec2, steps: int]

const
  dirs: array[4, Vec2] = [(0, -1), (1, 0), (0, 1), (-1, 0)]

proc `+`(l, r: Vec2): Vec2 =
  (l.x + r.x, l.y + r.y)

proc validPlot(input: seq[string], loc: Vec2): bool =
  loc.y >= 0 and loc.y < input.len and loc.x >= 0 and loc.x < input[0].len and input[loc.y][loc.x] != '#'

proc validPlotInf(input: seq[string], loc: Vec2): bool =
  var
    y = loc.y mod input.len
    x = loc.x mod input[0].len

  if y < 0:
    y = input.len + y
  if x < 0:
    x = input[0].len + x

  input[y][x] != '#'


proc getStartingPoint(input: seq[string]): Vec2 =
  for y in 0..<input.len:
    for x in 0..<input[0].len:
      if input[y][x] == 'S':
        return (x, y)

proc partOne(input: seq[string]): string =
  let startingPoint = input.getStartingPoint
  var
    q: Deque[State]
    seen: HashSet[State]
    reachable: HashSet[Vec2]

  q.addLast((startingPoint, 0))

  while q.len > 0:
    let state = q.popFirst
    if seen.contains(state):
      continue
    seen.incl(state)
    if state.steps == 64:
      reachable.incl(state.loc)
      continue

    for dir in dirs:
      let nextLoc = state.loc + dir
      if input.validPlot(nextLoc):
        q.addLast((nextLoc, state.steps + 1))

  $reachable.len

proc countReachableSquaresInQuadrant(reachable: HashSet[Vec2], input: seq[string], qx, qy: int): int =
  let
    w = input[0].len
    h = input.len
    sx = qx * w
    sy = qy * h
    ex = sx + w
    ey = sy + h
  var sum = 0
  for y in sy..<ey:
    for x in sx..<ex:
      if reachable.contains((x, y)):
        sum += 1
  sum

proc partTwo(input: seq[string]): string =
  let startingPoint = input.getStartingPoint
  var
    q: Deque[State]
    seen: HashSet[State]
    reachable: HashSet[Vec2]

  let
    targetSteps = 26501365
    targetMaps = (targetSteps - (input.len div 2)) div input.len

  # NOTES:
  # target steps, minus half the map size, is a perfect multiple of the map size.
  # the elf can walk unimpeded in any cardinal direction, so they can make it to the very end
  # of a map after target steps.
  #
  # After a certain number of odd steps, the elf will reach equilibrium (7717 for my input, I think),
  # but how many steps it takes depends on the starting square.
  #
  # It should be possible to calculate for 2xMapSize + 1/2xMapSize and then extrapolate?
  let
    sampleMaps = 2
    maxSteps = sampleMaps * input.len + (input.len div 2)

  q.addLast((startingPoint, 0))

  while q.len > 0:
    let state = q.popFirst
    if seen.contains(state):
      continue
    seen.incl(state)
    if state.steps == maxSteps:
      reachable.incl(state.loc)
      continue

    for dir in dirs:
      let nextLoc = state.loc + dir
      if input.validPlotInf(nextLoc):
        q.addLast((nextLoc, state.steps + 1))

  var lookup: Table[Vec2, int]
  for y in -sampleMaps..sampleMaps:
    for x in -sampleMaps..sampleMaps:
      lookup[(x, y)] = countReachableSquaresInQuadrant(reachable, input, x, y)


  # center
  var sum = lookup[(0, 0)]

  # cardinal endpoints
  sum += lookup[(-sampleMaps, 0)] + lookup[(sampleMaps, 0)] + lookup[(0, -sampleMaps)] + lookup[(0, sampleMaps)]

  # outer perimeter NW
  sum += targetMaps * lookup[(-2, -1)]
  # inner perimeter NW
  sum += (targetMaps - 1) * lookup[(-1, -1)]

  # outer perimeter NE
  sum += targetMaps * lookup[(2, -1)]
  # inner perimeter NE
  sum += (targetMaps - 1) * lookup[(1, -1)]

  # outer perimeter SW
  sum += targetMaps * lookup[(-2, 1)]
  # inner perimeter SW
  sum += (targetMaps - 1) * lookup[(-1, 1)]

  # outer perimeter SE
  sum += targetMaps * lookup[(2, 1)]
  # inner perimeter SE
  sum += (targetMaps - 1) * lookup[(1, 1)]

  # all the middle bits, alternating between the even/odd variants
  for i in 1..<targetMaps:
    if i mod 2 == 0:
      sum += i * 4 * lookup[(0, 0)]
    else:
      sum += i * 4 * lookup[(1, 0)]
  $sum

when isMainModule:
  echo "### DAY 21 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines
