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

proc partTwo(parts: PartList, workflows: WorkflowTable): string =
  "INCOMPLETE"

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

  bench(partOne(parts, workflows), partTwo(parts, workflows)):
    let
      inputs = input.strip.split("\n\n")
      parts = inputs[1].splitLines.map(parsePart)
      workflows = inputs[0].parseWorkflows
