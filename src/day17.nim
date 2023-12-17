import
  sugar,
  std/sets,
  std/options,
  std/sequtils,
  std/strutils,
  std/heapqueue,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec2 = tuple[x, y: int]
  Node = tuple[x, y, dx, dy, heatloss, straightsteps: int]

proc `<`(l, r: Node): bool =
  l.heatloss < r.heatloss

proc goStraight(n: Node, input: seq[seq[int]], maxsteps = 3): Option[Node] =
  if n.straightsteps >= maxsteps:
    return none(Node)

  let
    nx = n.x + n.dx
    ny = n.y + n.dy

  if nx >= 0 and nx < input[0].len and ny >= 0 and ny < input.len:
    some((nx, ny, n.dx, n.dy, n.heatloss + input[ny][nx], n.straightsteps + 1))
  else:
    none(Node)

proc goRight(n: Node, input: seq[seq[int]], minsteps = 0): Option[Node] =
  if n.straightsteps < minsteps:
    return none(Node)
  let
    od = (n.dx, n.dy)
    d = if od == (0, -1):
        (1, 0)
      elif od == (1, 0):
        (0, 1)
      elif od == (0, 1):
        (-1, 0)
      else:
        (0, -1)
    nx = n.x + d[0]
    ny = n.y + d[1]

  if nx >= 0 and nx < input[0].len and ny >= 0 and ny < input.len:
    some((nx, ny, d[0], d[1], n.heatloss + input[ny][nx], 1))
  else:
    none(Node)

proc goLeft(n: Node, input: seq[seq[int]], minsteps = 0): Option[Node] =
  if n.straightsteps < minsteps:
    return none(Node)
  let
    od = (n.dx, n.dy)
    d = if od == (0, -1):
        (-1, 0)
      elif od == (-1, 0):
        (0, 1)
      elif od == (0, 1):
        (1, 0)
      else:
        (0, -1)
    nx = n.x + d[0]
    ny = n.y + d[1]

  if nx >= 0 and nx < input[0].len and ny >= 0 and ny < input.len:
    some((nx, ny, d[0], d[1], n.heatloss + input[ny][nx], 1))
  else:
    none(Node)

proc partOne(input: seq[seq[int]]): string =
  var
    queue = initHeapQueue[Node]()
    seen: HashSet[tuple[x, y, dx, dy, ss: int]]

  queue.push((1, 0, 1, 0, input[0][1], 1))
  queue.push((0, 1, 0, 1, input[1][0], 1))

  while queue.len > 0:
    let n = queue.pop

    if (n.x, n.y, n.dx, n.dy, n.straightsteps) in seen:
      continue

    seen.incl((n.x, n.y, n.dx, n.dy, n.straightsteps))

    if n.x == input[0].len - 1 and n.y == input.len - 1:
      return $n.heatloss

    let
      straight = n.goStraight(input)
      right = n.goRight(input)
      left = n.goLeft(input)
    if straight.isSome:
      queue.push(straight.unsafeGet)
    if right.isSome:
      queue.push(right.unsafeGet)
    if left.isSome:
      queue.push(left.unsafeGet)

  "DNF"

proc partTwo(input: seq[seq[int]]): string =
  var
    queue = initHeapQueue[Node]()
    seen: HashSet[tuple[x, y, dx, dy, ss: int]]

  queue.push((1, 0, 1, 0, input[0][1], 1))
  queue.push((0, 1, 0, 1, input[1][0], 1))

  while queue.len > 0:
    let n = queue.pop

    if (n.x, n.y, n.dx, n.dy, n.straightsteps) in seen:
      continue

    seen.incl((n.x, n.y, n.dx, n.dy, n.straightsteps))

    if n.x == input[0].len - 1 and n.y == input.len - 1 and n.straightsteps >= 4:
      return $n.heatloss

    let
      straight = n.goStraight(input, 10)
      right = n.goRight(input, 4)
      left = n.goLeft(input, 4)
    if straight.isSome:
      queue.push(straight.unsafeGet)
    if right.isSome:
      queue.push(right.unsafeGet)
    if left.isSome:
      queue.push(left.unsafeGet)

  "DNF"

when isMainModule:
  echo "### DAY 17 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(l => l.map(c => int(c) - int('0')))
