import
  std/math,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Race = tuple[time, record: int]

proc partOne(input: seq[Race]): string =
  var product = 1
  for race in input:
    let
      time = race.time
      record = race.record

    # example: time 7 record 9
    # (7 - t)*t > 9
    # -t^2 + 7t > 9
    # t^2 - 7t < - 9
    # t^2 - 7t + 9 < 0
    # t > 7/2 +- sqrt((-7/2)^2 - 9)
    #
    # general
    # t > time/2 +- sqrt((time/2)^2 - record)

    # floor/ceil and then add/sub one, becuase the bounds are exclusive
    let lowerBound = int(floor(time / 2 - sqrt((time / 2)^2 - float(record)))) + 1
    let upperBound = int(ceil(time / 2 + sqrt((time / 2)^2 - float(record)))) - 1

    product *= upperBound - lowerBound + 1

  $product

proc partTwo(race: Race): string =
  let
    time = race.time
    record = race.record

  let lowerBound = int(floor(time / 2 - sqrt((time / 2)^2 - float(record)))) + 1
  let upperBound = int(ceil(time / 2 + sqrt((time / 2)^2 - float(record)))) - 1

  $(upperBound - lowerBound + 1)

when isMainModule:
  echo "### DAY 06 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(p2parsed)):
    let
      lines = input.strip.splitLines
      times = lines[0].splitWhitespace[1..^1].map(parseInt)
      records = lines[1].splitWhitespace[1..^1].map(parseInt)
      parsed = zip(times, records)
      p2time = lines[0].splitWhitespace[1..^1].join("").parseInt
      p2record = lines[1].splitWhitespace[1..^1].join("").parseInt
      p2parsed = (p2time, p2record)
