import
  sugar,
  algorithm,
  std/tables,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Hand = tuple[cards: string, bid: int]
  Rank = enum
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind

proc getValue(card: char): int =
  case card:
    of 'A': 14
    of 'K': 13
    of 'Q': 12
    of 'J': 11
    of 'T': 10
    else: int(card) - int('0')

proc getRank(hand: Hand): Rank =
  let cardCounts = hand.cards.toCountTable.values.toSeq

  if cardCounts.any(c => c == 5):
    FiveOfAKind
  elif cardCounts.any(c => c == 4):
    FourOfAKind
  elif cardCounts.any(c => c == 3) and cardCounts.any(c => c == 2):
    FullHouse
  elif cardCounts.any(c => c == 3):
    ThreeOfAKind
  elif cardCounts.count(2) == 2:
    TwoPair
  elif cardCounts.any(c => c == 2):
    OnePair
  else:
    HighCard

proc `==`(left, right: Hand): bool =
  left.cards == right.cards

proc `<`(left, right: Hand): bool =
  if left.getRank == right.getRank:
    for i in 0..<5:
      if left.cards[i].getValue == right.cards[i].getValue:
        continue
      return left.cards[i].getValue < right.cards[i].getValue
    false
  else:
    left.getRank < right.getRank

proc partOne(input: seq[Hand]): string =
  let sorted = input.sorted
  var sum = 0
  for i in 1..input.len:
    sum += sorted[i - 1].bid * i
  $sum

proc partTwo(input: seq[Hand]): string =
  "INCOMPLETE"

when isMainModule:
  echo "### DAY 07 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let parsed = input.strip.splitLines.map(proc (line: string): Hand =
      let parts = line.splitWhitespace
      (cards: parts[0], bid: parts[1].parseInt))
