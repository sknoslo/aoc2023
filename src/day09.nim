import
  math,
  sugar,
  std/sequtils,
  std/strutils,
  std/algorithm,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

proc nextVal(report: seq[int]): int =
  if report.all(v => v == 0):
    0
  else:
    var diff = newSeq[int](report.len - 1)
    for i in 1..<report.len:
      diff[i-1] = report[i] - report[i-1]
    report[^1] + nextVal(diff)

proc partOne(input: seq[seq[int]]): string =
  $input.map(nextVal).sum

proc partTwo(input: seq[seq[int]]): string =
  $input.map(report => report.reversed).map(nextVal).sum

when isMainModule:
  echo "### DAY 09 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(line => line.splitWhitespace.map(parseInt))
