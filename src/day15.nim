import
  std/math,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

proc hash(s: string): int =
  var h = 0
  for c in s:
    h = h + int(c)
    h = h * 17
    h = h mod 256
  h

proc findByLabel(lenses: seq[string], label: string): int =
  for i in 0..<lenses.len:
    if lenses[i].startsWith(label):
      return i
  -1

proc partOne(input: seq[string]): string =
  $input.map(hash).sum

proc partTwo(input: seq[string]): string =
  var boxes: array[0..255, seq[string]]
  for i in input:
    if i[^1] == '-':
      let
        label = i[0..^2]
        h = hash(label)
        idx = boxes[h].findByLabel(label)

      if idx != -1:
        boxes[h].delete(idx)
    else:
      let
        label = i.split('=')[0]
        h = hash(label)
        idx = boxes[h].findByLabel(label)
      if idx != -1:
        boxes[h][idx] = i
      else:
        boxes[h].add(i)

  var sum = 0
  for (bi, box) in boxes.pairs:
    for (si, lense) in box.pairs:
      let
        bn = bi + 1
        sn = si + 1
        fl = lense.split('=')[1].parseInt
      sum += bn * sn * fl

  $sum

when isMainModule:
  echo "### DAY 15 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.split(',')
