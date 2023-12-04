import
  math,
  std/sets,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Card = tuple[id: int, winners, mine: seq[int]]

proc partOne(cards: seq[Card]): string =
  var sum = 0
  for card in cards:
    let
      winnerSet = card.winners.toHashSet
      mySet = card.mine.toHashSet

    let matches = winnerSet * mySet
    if matches.len > 0:
      sum += 2 ^ (matches.len - 1)

  $sum

proc partTwo(cards: seq[Card]): string =
  var multipliers = newSeq[int](cards.len)

  for card in cards:
    let
      winnerSet = card.winners.toHashSet
      mySet = card.mine.toHashSet

    multipliers[card.id - 1] += 1

    let
      matches = winnerSet * mySet
      mult = multipliers[card.id - 1]

    for i in 0..<matches.len:
      multipliers[card.id + i] += mult

  $multipliers.sum

when isMainModule:
  echo "### DAY 04 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(proc (line: string): Card =
      let parts = line.replace("Card", "").replace(" |", ":").strip.split(": ")
      (id: parts[0].parseInt, winners: parts[1].splitWhitespace.map(parseInt), mine: parts[2].splitWhitespace.map(parseInt))
    )
