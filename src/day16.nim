import
  std/sets,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec2 = tuple[x, y: int]

const
  RIGHT = (1, 0)
  DOWN = (0, 1)
  LEFT = (-1, 0)
  UP = (0, -1)

proc `+`(l, r: Vec2): Vec2 =
  (l.x + r.x, l.y + r.y)

proc step(input: seq[string], loc, dir: Vec2, visited: var HashSet[Vec2], seen: var HashSet[tuple[loc, dir: Vec2]]) =
  if loc.x >= 0 and loc.x < input[0].len and loc.y >= 0 and loc.y < input.len:
    if (loc, dir) in seen:
      return
    seen.incl(( loc, dir))
    visited.incl(loc)
    case input[loc.y][loc.x]:
      of '/':
        let nextDir =
          if dir == RIGHT:
            UP
          elif dir == LEFT:
            DOWN
          elif dir == DOWN:
            LEFT
          else:
            RIGHT
        input.step(loc + nextDir, nextDir, visited, seen)
      of '\\':
        let nextDir =
          if dir == RIGHT:
            DOWN
          elif dir == LEFT:
            UP
          elif dir == DOWN:
            RIGHT
          else:
            LEFT
        input.step(loc + nextDir, nextDir, visited, seen)
      of '-':
        if dir == UP or dir == DOWN:
          input.step(loc + RIGHT, RIGHT, visited, seen)
          input.step(loc + LEFT, LEFT, visited, seen)
        else:
          input.step(loc + dir, dir, visited, seen)
      of '|':
        if dir == RIGHT or dir == LEFT:
          input.step(loc + DOWN, DOWN, visited, seen)
          input.step(loc + UP, UP, visited, seen)
        else:
          input.step(loc + dir, dir, visited, seen)
      else:
        input.step(loc + dir, dir, visited, seen)

proc partOne(input: seq[string]): string =
  var
    visited: HashSet[Vec2]
    seen: HashSet[tuple[loc, dir: Vec2]]
  input.step((0, 0), RIGHT, visited, seen)

  $visited.len

proc partTwo(input: seq[string]): string =
  let
    mx = input[0].len - 1
    my = input.len - 1
  var max = 0
  for y in 0..my:
    for (x, dir) in [(0, RIGHT), (mx, LEFT)]:
      var
        visited: HashSet[Vec2]
        seen: HashSet[tuple[loc, dir: Vec2]]
      input.step((x, y), dir, visited, seen)
      max = max(visited.len, max)

  for x in 0..mx:
    for (y, dir) in [(0, DOWN), (my, UP)]:
      var
        visited: HashSet[Vec2]
        seen: HashSet[tuple[loc, dir: Vec2]]
      input.step((x, y), dir, visited, seen)
      max = max(visited.len, max)

  for (x, y, dirs) in [(0, 0, [RIGHT, DOWN]), (mx, 0, [LEFT, DOWN]), (0, my, [RIGHT, UP]), (mx, my, [LEFT, UP])]:
    for dir in dirs:
      var
        visited: HashSet[Vec2]
        seen: HashSet[tuple[loc, dir: Vec2]]
      input.step((x, y), dir, visited, seen)
      max = max(visited.len, max)

  $max

when isMainModule:
  echo "### DAY 00 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines
