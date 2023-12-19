import
  std/tables,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Part = tuple[x, m, a, s: int]
  Workflow = tuple[name: string, rules: seq[string]]
  WorkflowTable = Table[string, Workflow]
  PartList = seq[Part]
  Rule = tuple[attr, cmp: char, val: int, result: string]
  PartIntervals = tuple[min, max: Part]

proc sum(part: Part): int =
  part.x + part.m + part.a + part.s

proc attrVal(part: Part, c: char): int =
  case c:
    of 'x':
      part.x
    of 'm':
      part.m
    of 'a':
      part.a
    of 's':
      part.s
    else:
      int.low

proc setAttrVal(part: var Part, c: char, val: int) =
  case c:
    of 'x':
      part.x = val
    of 'm':
      part.m = val
    of 'a':
      part.a = val
    else:
      part.s = val

proc splitInterval(intervals: PartIntervals, remainder: var PartIntervals, rule: Rule): PartIntervals =
  result = intervals
  if rule.cmp == '<':
    if intervals.min.attrVal(rule.attr) < rule.val and intervals.max.attrVal(rule.attr) >= rule.val:
      result.max.setAttrVal(rule.attr, rule.val - 1)
      remainder.min.setAttrVal(rule.attr, rule.val)
  else:
    if intervals.max.attrVal(rule.attr) > rule.val and intervals.min.attrVal(rule.attr) <= rule.val:
      remainder.max.setAttrVal(rule.attr, rule.val)
      result.min.setAttrVal(rule.attr, rule.val + 1)

proc isWithinInterval(intervals: PartIntervals, rule: Rule): bool =
  if rule.cmp == '<':
    intervals.min.attrVal(rule.attr) < rule.val
  else:
    intervals.max.attrVal(rule.attr) > rule.val

proc parseRule(input: string): Rule =
  let i = input.find(':')
  doAssert i >= 0
  (input[0], input[1], input[2..<i].parseInt, input[i+1..^1])

proc partOne(parts: PartList, workflows: WorkflowTable): string =
  var sum = 0
  for part in parts:
    var next = "in"

    while next != "A" and next != "R":
      let workflow = workflows[next]
      for rule in workflow.rules:
        if rule == "A" or rule == "R" or not rule.contains(':'):
          next = rule
        else:
          let r = rule.parseRule
          if r.cmp == '<' and part.attrVal(r.attr) < r.val:
            next = r.result
            break
          elif r.cmp == '>' and part.attrVal(r.attr) > r.val:
            next = r.result
            break

    if next == "A":
      sum += part.sum

  $sum

proc getPartIntervals(intervals: PartIntervals, currentWorkflow: string, workflows: WorkflowTable): seq[PartIntervals] =
  if currentWorkflow == "A":
    result.add(intervals)
  elif currentWorkflow != "R":
    let workflow = workflows[currentWorkflow]
    var nextIntervals = intervals
    for rule in workflow.rules:
      if rule.contains(':'):
        # 1. check if current interval rule is within current interval
        #    a. shrink interval as needed, and add to result
        #    b. carry over remaining interval to next rule
        # 2. if not, carry over to next rule
        let r = rule.parseRule
        if nextIntervals.isWithinInterval(r):
          let tmp = getPartIntervals(nextIntervals.splitInterval(nextIntervals, r), r.result, workflows)
          result.add(tmp)
      else:
        result.add(getPartIntervals(nextIntervals, rule, workflows))

proc partTwo(workflows: WorkflowTable): string =
  let
    min = Part((1, 1, 1, 1))
    max = Part((4000, 4000, 4000, 4000))
    intervals = getPartIntervals((min, max), "in", workflows)
  var sum = 0
  for i in intervals:
    sum += (i.max.x - i.min.x + 1) * (i.max.m - i.min.m + 1) * (i.max.a - i.min.a + 1) * (i.max.s - i.min.s + 1)

  $sum

proc parsePart(input: string): Part =
  let nums = input.multiReplace(("{x=", ""), ("m=", ""), ("a=", ""), ("s=", ""), ("}", "")).split(',').map(parseInt)

  (nums[0], nums[1], nums[2], nums[3])

proc parseWorkflow(input: string): Workflow =
  let parts = input.replace("}", "").split('{')

  (parts[0], parts[1].split(','))

proc parseWorkflows(input: string): WorkflowTable =
  for line in input.splitLines:
    let workflow = line.parseWorkflow
    result[workflow.name] = workflow

when isMainModule:
  echo "### DAY 19 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parts, workflows), partTwo(workflows)):
    let
      inputs = input.strip.split("\n\n")
      parts = inputs[1].splitLines.map(parsePart)
      workflows = inputs[0].parseWorkflows
