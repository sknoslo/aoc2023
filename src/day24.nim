import
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec3 = tuple[x, y, z: float]
  HailStone = tuple[pos, vel: Vec3]

proc toVec3(v: seq[float]): Vec3 =
  doAssert v.len == 3
  (v[0], v[1], v[2])

proc parseHailStone(input: string): HailStone =
  let
    parts = input.splitWhitespace.join("").split("@")
    pos = parts[0].split(",").map(parseFloat).toVec3
    vel = parts[1].split(",").map(parseFloat).toVec3

  (pos, vel)

proc partOne(input: seq[HailStone]): string =
  const
    min = 200000000000000f
    max = 400000000000000f

  # x = x0 + vx*t
  # t = (x - x0)/vx
  # t = (y - y0)/vy
  # (x - x0)/vx = (y - y0)/vy
  #
  # y = (vy(x - x0))/vx + y0
  # y = (vy/vx)x - (vy/vx)x0 +y0
  #
  # (vya/vxa)x - (vya/vxa)x0a + y0a = (vyb/vxb)x - (vyb/vxb)x0b + y0b
  # (vya/vxa)x - (vyb/vxb)x = -(vyb/vxb)x0b + y0b + (vya/vxa)x0a - y0a
  # (vya/vxa - vyb/vxb)x = (-(vyb/vxb)x0b + y0b + (vya/vxa)x0a - y0a)
  # x = (-(vyb/vxb)x0b + y0b + (vya/vxa)x0a - y0a)/(vya/vxa - vyb/vxb)
  var sum = 0

  for (i, a) in input[0..^2].pairs:
    for b in input[i+1..^1]:
      let
        # x = (-a.vel.x * b.vel.y * b.pos.x + b.vel.x * (b.pos.y - a.pos.y + a.vel.y * a.pos.x)) / (b.vel.x * a.vel.y - a.vel.x * b.vel.y)
        x = (-(b.vel.y/b.vel.x) * b.pos.x + b.pos.y + (a.vel.y/a.vel.x)*a.pos.x - a.pos.y)/(a.vel.y/a.vel.x - b.vel.y/b.vel.x)
        y = (a.vel.y * (x - a.pos.x)) / a.vel.x + a.pos.y
        at = (y - b.pos.y)/b.vel.y
        bt = (y - a.pos.y)/a.vel.y

      if x >= min and x <= max and y >= min and y <= max and at >= 0f and bt >= 0f:
        sum += 1
  $sum

proc partTwo(input: seq[HailStone]): string =
  "INCOMPLETE"

when isMainModule:
  echo "### DAY 24 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(parseHailStone)
