import
  sugar,
  std/math,
  std/tables,
  std/strutils,
  std/sequtils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Node = tuple[left, right: string]
  Documents = tuple[directions: seq[char], network: Table[string, Node]]

proc partOne(input: Documents): string =
  var
    curr = "AAA"
    steps = 0
  while curr != "ZZZ":
    let direction = input.directions[steps mod input.directions.len]
    if direction == 'L':
      curr = input.network[curr].left
    else:
      curr = input.network[curr].right
    steps += 1
  $steps

proc partTwo(input: Documents): string =
  var
    periods: Table[string, int]
    currNodes = input.network.keys.toSeq.filter(key => key[^1] == 'A')
    steps = 0
  while periods.len < currNodes.len:
    for i in 0..<currNodes.len:
      let
        curr = currNodes[i]
        direction = input.directions[steps mod input.directions.len]
      if direction == 'L':
        currNodes[i] = input.network[curr].left
      else:
        currNodes[i] = input.network[curr].right

      if currNodes[i][^1] == 'Z' and not periods.hasKey(currNodes[i]):
        periods[currNodes[i]] = steps + 1
    steps += 1
  $periods.values.toSeq.lcm

when isMainModule:
  echo "### DAY 08 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let
      parts = input.strip.split("\n\n")
      directions = parts[0].toSeq
    var
      network: Table[string, Node]

    for line in parts[1].splitLines:
      let nodeParts = line.replace(" = (", " ").replace(", ", " ").replace(")", "").split(" ")
      network[nodeParts[0]] = (nodeParts[1], nodeParts[2])

    let parsed = (directions, network)
