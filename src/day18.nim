import
  std/tables,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec2 = tuple[x, y: int]
  Instruction = tuple[dir: char, length: int, color: string]

const
  UP = Vec2((0, -1))
  RIGHT = Vec2((1, 0))
  DOWN = Vec2((0, 1))
  LEFT = Vec2((-1, 0))

proc `+`(l, r: Vec2): Vec2 =
  (l.x + r.x, l.y + r.y)

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


proc partTwo(input: seq[Instruction]): string =
  var
    lagoon: Table[Vec2, string]
    perimeter = 0

  for inst in input:
    let realInst = inst.convert
    perimeter += realInst.length
    echo $realInst

  echo "perimeter = " & $perimeter & " cubic meters"

  "INCOMPLETE"

when isMainModule:
  echo "### DAY 18 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(parseInstruction)
