import
  sugar,
  std/tables,
  std/sequtils,
  std/strutils,
  std/algorithm,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Vec3 = tuple[x, y, z: int]
  Brick = tuple[min, max: Vec3]

iterator downTo(a, b: int): int =
  var next = a
  while next >= b:
    yield next
    next -= 1

proc toVec3(i: seq[int]): Vec3 =
  doAssert i.len == 3, "Vec3 can only be made from a sequence of 3 numbers"
  (i[0], i[1], i[2])

proc dropOne(b: Brick): Brick =
  result = b
  result.min.z -= 1
  result.max.z -= 1

proc hasCollision(b, ob: Brick): bool {.inline.} =
  let
    cx = b.min.x <= ob.max.x and b.max.x >= ob.min.x
    cy = b.min.y <= ob.max.y and b.max.y >= ob.min.y
    cz = b.min.z <= ob.max.z and b.max.z >= ob.min.z
  cx and cy and cz

proc hasCollision(b: Brick, obs: seq[Brick]): bool =
  # TODO: optimization, if you go in reverse, you'll probably have to check fewer items
  for ob in obs:
    if b.hasCollision(ob):
      return true
  false

proc partOne(bricks: seq[Brick]): string =
  let sorted = bricks.sortedByIt(it.min.z)
  var settled = newSeqOfCap[Brick](bricks.len)

  for fb in sorted:
    var
      rb = fb
      nb = fb.dropOne

    while nb.min.z >= 1 and not nb.hasCollision(settled):
      rb = nb
      nb = rb.dropOne

    settled.add(rb)

  var
    bmin: Table[int, seq[Brick]]
    bmax: Table[int, seq[Brick]]

  for s in settled:
    bmin.mgetOrPut(s.min.z, @[]).add(s)
    bmax.mgetOrPut(s.max.z, @[]).add(s)

  var total = 0

  for (i, s) in settled.pairs:
    var ontop: seq[Brick]
    if bmin.hasKey(s.max.z + 1):
      for o in bmin[s.max.z + 1]:
        if o.dropOne.hasCollision(s):
          ontop.add(o)

    var requiredFor = ontop.len
    for ot in ontop:
      var supportedBy = 0
      for o in bmax[ot.min.z - 1]:
        if ot.dropOne.hasCollision(o):
          supportedBy += 1
      if supportedBy > 1:
        requiredFor -= 1

    if requiredFor == 0:
      total += 1

  $total

proc partTwo(bricks: seq[Brick]): string =
  let sorted = bricks.sortedByIt(it.min.z)
  var settled = newSeqOfCap[Brick](bricks.len)

  for fb in sorted:
    var
      rb = fb
      nb = fb.dropOne

    while nb.min.z >= 1 and not nb.hasCollision(settled):
      rb = nb
      nb = rb.dropOne

    settled.add(rb)

  var
    bmin: Table[int, seq[Brick]]
    bmax: Table[int, seq[Brick]]

  for s in settled:
    bmin.mgetOrPut(s.min.z, @[]).add(s)
    bmax.mgetOrPut(s.max.z, @[]).add(s)


  # brute force solution:
  # run same algo as part 1, except store required bricks.
  # for each required brick, remove it from a copy of settled,
  # and then simulate the dropping again, counting the number
  # of bricks that are changed
  # there is _maybe_ a way to use dynamic programming
  # to avoid re-calculating, but my brain can't make it work?

  var requiredBricks: seq[Brick]

  for (i, s) in settled.pairs:
    var ontop: seq[Brick]
    if bmin.hasKey(s.max.z + 1):
      for o in bmin[s.max.z + 1]:
        if o.dropOne.hasCollision(s):
          ontop.add(o)

    var requiredFor = ontop.len
    for ot in ontop:
      var supportedBy = 0
      for o in bmax[ot.min.z - 1]:
        if ot.dropOne.hasCollision(o):
          supportedBy += 1
      if supportedBy > 1:
        requiredFor -= 1

    if requiredFor > 0:
      requiredBricks.add(s)

  var total = 0
  for req in requiredBricks:
    let
      reqCopy = req
      without = settled.filter(b => b != reqCopy)
    var nextSettled = newSeqOfCap[Brick](without.len)

    for fb in without:
      var
        rb = fb
        nb = fb.dropOne
        dropped = false

      while nb.min.z >= 1 and not nb.hasCollision(nextSettled):
        dropped = true
        rb = nb
        nb = rb.dropOne

      nextSettled.add(rb)
      if dropped:
        total += 1

  $total

when isMainModule:
  echo "### DAY 22 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(proc (line: string): Brick =
      let parts = line.split('~')
      (parts[0].split(',').map(parseInt).toVec3, parts[1].split(',').map(parseInt).toVec3))
