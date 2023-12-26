import
  std/sets,
  std/deques,
  std/tables,
  std/strutils,
  std/sequtils,
  std/algorithm,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

proc countNodesFrom(input: Table[string, seq[string]], start: string): int =
  var
    q: Deque[string]
    visited: HashSet[string]

  q.addLast(start)

  while q.len > 0:
    let n = q.popFirst

    if visited.contains(n):
      continue

    visited.incl(n)

    for conn in input[n]:
      q.addLast(conn)
  visited.len

proc partOne(input: Table[string, seq[string]]): string =
  const discardWires = [("zvk", "sxx"), ("njx", "pbx"), ("sss", "pzr")]
  var wires = input
  for wire in discardWires:
    wires[wire[0]].delete(wires[wire[0]].find(wire[1]))
    wires[wire[1]].delete(wires[wire[1]].find(wire[0]))

  $(wires.countNodesFrom(discardWires[0][0]) * wires.countNodesFrom(discardWires[0][1]))

proc partTwo(): string =
  "INCOMPLETE"

when isMainModule:
  echo "### DAY 25 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"


  # UNCOMMENT AND PIPE INTO GRAPHVIZ (neato -Tsvg) and then open the svg and manually find the 3 connecting wires :)
  #
  # echo "digraph {"
  # for line in input.strip.splitLines:
  #   let
  #     parts = line.split(": ")
  #     key = parts[0]
  #     connections = parts[1]

  #   echo key & " -> { " & connections & " }"
  # echo "}"

  bench(partOne(parsed), partTwo()):
    var parsed: Table[string, seq[string]]

    for line in input.strip.splitLines:
      let
        parts = line.split(": ")
        key = parts[0]
        connections = parts[1].splitWhitespace

      for conn in connections:
        parsed.mgetOrPut(key, @[]).add(conn)
        parsed.mgetOrPut(conn, @[]).add(key)
