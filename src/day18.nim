import
  std/tables,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec2 = tuple[x, y: int]
  Mat2x2 = tuple[x1, x2, y1, y2: int]
  Instruction = tuple[dir: char, length: int, color: string]

const
  UP = Vec2((0, -1))
  RIGHT = Vec2((1, 0))
  DOWN = Vec2((0, 1))
  LEFT = Vec2((-1, 0))

proc `+`(l, r: Vec2): Vec2 =
  (l.x + r.x, l.y + r.y)

proc `*`(l: Vec2, r: int): Vec2 =
  (l.x * r, l.y * r)

proc determinant(mat: Mat2x2): int =
  mat.x1 * mat.y2 - mat.x2 * mat.y1

proc minMax(lagoon: Table[Vec2, string]): tuple[min, max: Vec2] =
  var
    minx = 100000000
    maxx = -100000000
    miny = 100000000
    maxy = -100000000

  for (x, y) in lagoon.keys:
    if x < minx:
      minx = x
    if x > maxx:
      maxx = x
    if y < miny:
      miny = y
    if y > maxy:
      maxy = y
  ((minx, miny), (maxx, maxy))

proc dig(lagoon: var Table[Vec2, string], curr: Vec2, instruction: Instruction): Vec2 =
  let step = case instruction.dir:
    of 'U':
      UP
    of 'R':
      RIGHT
    of 'D':
      DOWN
    else:
      LEFT

  var nloc = curr
  for i in 0..<instruction.length:
    nloc = nloc + step
    lagoon[nloc] = instruction.color

  nloc

proc parseInstruction(input: string): Instruction =
  let parts = input.splitWhitespace
  result.dir = parts[0][0]
  result.length = parts[1].parseInt
  result.color = parts[2]

proc partOne(input: seq[Instruction]): string =
  var
    lagoon: Table[Vec2, string]
    loc: Vec2

  for inst in input:
    loc = lagoon.dig(loc, inst)

  let
    mm = lagoon.minMax
    min = mm.min
    max = mm.max

  var
    inside = true
    filled = lagoon

  for y in min.y..max.y:
    inside = false
    for x in min.x..max.x:
      if lagoon.hasKey((x, y)):
        filled[(x, y)] = lagoon[(x, y)]
        if not lagoon.hasKey((x - 1, y)) and not lagoon.hasKey((x + 1, y)):
          # simple line
          inside = not inside
        elif lagoon.hasKey((x, y - 1)) and lagoon.hasKey((x + 1, y)):
          # L shape
          inside = not inside
        elif lagoon.hasKey((x, y - 1)) and lagoon.hasKey((x - 1, y)):
          # J shape
          inside = not inside
      elif inside:
        filled[(x, y)] = "#000000"

  $filled.len

proc convert(inst: Instruction): Instruction =
  const dirs = "RDLU"
  # (#123456)
  # 012345678
  let
    length = inst.color[2..6].parseHexInt
    i = inst.color[7..7].parseInt
    dir = dirs[i]
  (dir, length, inst.color)

proc outsideLength(instructions: seq[Instruction], i: int): int =
  # |#
  # L#########7
  #          #|
  #
  # |#       #|
  # L#########J
  #
  # #|         |#
  # #L_________J#
  # #############
  let
    pi = if i == 0: instructions.len - 1 else: i - 1
    ni = if i == instructions.len - 1: 0 else: i + 1
    curr = instructions[i]
    prev = instructions[pi]
    next = instructions[ni]

  if prev.dir == next.dir:
    return curr.length

  case curr.dir:
    of 'U':
      if prev.dir == 'R':
        return curr.length - 1
      else:
        return curr.length + 1
    of 'R':
      if prev.dir == 'D':
        return curr.length - 1
      else:
        return curr.length + 1
    of 'D':
      if prev.dir == 'L':
        return curr.length - 1
      else:
        return curr.length + 1
    else:
      if prev.dir == 'U':
        return curr.length - 1
      else:
        return curr.length + 1

proc partTwo(input: seq[Instruction]): string =
  var
    lagoon: Table[Vec2, string]
    loc: Vec2
    sum = 0

  let instructions = input.map(convert)

  # Problem space is way too large for the p1 solution, so we'll simplify to calculating just
  # the corners of the polygon, then we'll google an algorithm for calculating the area :)
  #
  # Shoelace formula:
  # Sum the determinant of the matrices defined by each corner in the trench and then divide by 2
  #
  # The tricky bit is discovering if we are inside or outside of the thing. If we start at the
  # left-most highest point, treat all right turns as being on the outside, and all left turns as
  # being inside?
  for (i, inst) in instructions.pairs:
    let
      step = case inst.dir:
        of 'U':
          UP
        of 'R':
          RIGHT
        of 'D':
          DOWN
        else:
          LEFT
      scale = instructions.outsideLength(i)
      nloc = loc + (step * scale)
      mat = Mat2x2((loc.x, nloc.x, loc.y, nloc.y))
      det = mat.determinant

    loc = nloc
    sum += det

  $(sum div 2)

when isMainModule:
  echo "### DAY 18 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(parseInstruction)
