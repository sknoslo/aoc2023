import
  sugar,
  std/math,
  std/tables,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  ConditionRecord = tuple[condition: string, runlen: seq[int]]

proc parseRecord(line: string): ConditionRecord =
  let parts = line.splitWhitespace
  result.condition = parts[0]
  result.runlen = parts[1].split(',').map(parseInt)

proc isMatch(condition, candidate: string): bool =
  doAssert condition.len == candidate.len

  for i in 0..<condition.len:
    if condition[i] == '?':
      continue
    if condition[i] != candidate[i]:
      return false
  true

proc genSubConditions(runlen: seq[int], remainingdots: int, pattern: string, index: int): seq[string] =
  if runlen.len == 0:
    return @['.'.repeat(remainingdots)]

  let
    run = runlen[0]
    rest = runlen[1..^1]
    restcount = rest.sum
    offset = if rest.len > 0: 1 else: 0

  for i in 0..<remainingdots - rest.len + 1 + offset:
    let s = '.'.repeat(i) & '#'.repeat(run) & '.'.repeat(offset)
    for sub in genSubConditions(rest, remainingdots - i - offset, pattern, index + s.len):
      result.add(s & sub)

proc genPossibleConditions(record: ConditionRecord): seq[string] =
  genSubConditions(record.runlen, record.condition.len - record.runlen.sum, record.condition, 0)

proc partOne(input: seq[ConditionRecord]): string =
  var sum = 0
  for record in input:
    for candidate in genPossibleConditions(record):
      if isMatch(record.condition, candidate):
        sum += 1
  $sum

proc partTwo(input: seq[ConditionRecord]): string =
  return "nope"
  var sum = 0
  for record in input:
    let
      c = record.condition
      unfolded = ConditionRecord(([c, c, c, c, c].join("?"), record.runlen.repeat(5).concat))

    # this is WAAAAAAAAYYYYYY too slow. Need to find a way to count without actually generating strings
    # dynamic programming???
    sum += genPossibleConditions(unfolded).len
  $sum

when isMainModule:
  echo "### DAY 12 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(parseRecord)
    var maxCount = 0
    for count in parsed.map(x => x.condition.count('?')):
      maxCount = if count > maxCount: count else: maxCount
