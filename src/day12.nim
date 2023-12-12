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

var memo: Table[tuple[runlen: seq[int], pattern: string], int]
proc countSubConditions(runlen: seq[int], pattern: string): int =
  let key = (runlen, pattern)
  if memo.hasKey(key):
    return memo[key]

  if runlen.len == 0:
    result = if isMatch(pattern, '.'.repeat(pattern.len)): 1 else: 0
  else:
    let
      run = runlen[0]
      rest = runlen[1..^1]
      restcount = rest.sum
      offset = if rest.len > 0: 1 else: 0
      maxsubstr = pattern.len - restcount - rest.len

    for i in 0..<maxsubstr:
      let s = '.'.repeat(i) & '#'.repeat(run) & '.'.repeat(offset)
      if s.len <= pattern.len and isMatch(pattern.substr(0, s.len-1), s):
        result += countSubConditions(rest, pattern.substr(s.len))

  memo[key] = result

proc partTwo(input: seq[ConditionRecord]): string =
  var sum = 0
  for record in input:
    let
      c = record.condition
      unfolded = ConditionRecord(([c, c, c, c, c].join("?"), record.runlen.repeat(5).concat))

    sum += countSubConditions(unfolded.runlen, unfolded.condition)
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
