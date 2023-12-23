import
  std/sets,
  std/tables,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec2 = tuple[x, y: int]
  State = tuple
    loc: Vec2
    visited: HashSet[Vec2]
    len: int
  State2 = tuple
    loc, prev: Vec2
    len: int

const
  dirs: array[4, Vec2] = [(0, -1), (1, 0), (0, 1), (-1, 0)]
  invalid = "v<^>"

proc `+`(l, r: Vec2): Vec2 =
  (l.x + r.x, l.y + r.y)

proc partOne(input: seq[string]): string =
  let
    w = input[0].len
    h = input.len
    s = Vec2((input[0].find('.'), 0))
    e = Vec2((input[^1].find('.'), h - 1))

  var
    q: seq[State]
    longest = 0

  q.add((s, [s].toHashSet, 0))

  while q.len > 0:
    let state = q.pop

    if state.loc == e:
      if state.len > longest:
        longest = state.len
      continue

    for (i, dir) in dirs.pairs:
      let
        nloc = state.loc + dir
      if not state.visited.contains(nloc) and nloc.x >= 0 and nloc.y >= 0 and nloc.x < w and nloc.y < h and input[nloc.y][nloc.x] != '#' and input[nloc.y][nloc.x] != invalid[i]:
        var nvisited = state.visited
        nvisited.incl(nloc)
        q.add((nloc, nvisited, state.len + 1))

  $longest

proc isNode(loc: Vec2, input: seq[string]): bool =
  let
    w = input[0].len
    h = input.len
  var c = 0
  for d in dirs:
    let n = loc + d
    if n.x >= 0 and n.y >= 0 and n.x < w and n.y < h and input[n.y][n.x] != '#':
      c += 1
  c > 2

proc isTile(loc: Vec2, input: seq[string]): bool =
  let
    w = input[0].len
    h = input.len
  loc.x >= 0 and loc.y >= 0 and loc.x < w and loc.y < h and input[loc.y][loc.x] != '#'

var cache: Table[Vec2, seq[tuple[loc: Vec2, dist: int]]]

proc getConnectedNodes(loc, exit: Vec2, input: seq[string]): seq[tuple[loc: Vec2, dist: int]] =
  if not cache.hasKey(loc):
    cache[loc] = @[]

    var q: seq[State2]
    q.add((loc, loc, 0))

    while q.len > 0:
      let n = q.pop

      if n.loc != loc and n.loc.isNode(input) or n.loc == exit:
        cache[loc].add((n.loc, n.len))
        continue

      for dir in dirs:
        let nloc = n.loc + dir
        if nloc.isTile(input) and nloc != n.prev:
          q.add((nloc, n.loc, n.len + 1))

  cache[loc]

proc partTwo(input: seq[string]): string =
  # convert maze to a graph (on demand) to avoid maintaining
  # state for all the inbetween tiles that don't have real
  # decisions. This is still horribly slow, because it has
  # to perform an exhaustive search to find the longest path.
  let
    w = input[0].len
    h = input.len
    s = Vec2((input[0].find('.'), 0))
    e = Vec2((input[^1].find('.'), h - 1))

  var
    q: seq[State]
    longest = 0

  q.add((s, [s].toHashSet, 0))

  while q.len > 0:
    let state = q.pop

    if state.loc == e:
      if state.len > longest:
        longest = state.len
      continue

    let connectedNodes = state.loc.getConnectedNodes(e, input)

    for node in connectedNodes:
      if not state.visited.contains(node.loc):
        var nvisited = state.visited
        nvisited.incl(node.loc)
        q.add((node.loc, nvisited, state.len + node.dist))

  $longest

when isMainModule:
  echo "### DAY 23 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines
