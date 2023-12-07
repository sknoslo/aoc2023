import
  std/options,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  MapRange = tuple[srcStart, destStart, rangeLen: int]
  Mapping = tuple[src, dest: string, ranges: seq[MapRange]]
  Almanac = tuple[seeds: seq[int], mappings: seq[Mapping]]

proc parseMapRange(input: string): MapRange =
  let parts = input.splitWhitespace.map(parseInt)
  (srcStart: parts[1], destStart: parts[0], rangeLen: parts[2])

proc parseMapping(input: string): Mapping =
  let
    lines = input.splitLines
    labels = lines[0].replace(" map:", "").split("-to-")

  (src: labels[0], dest: labels[1], ranges: lines[1..<lines.len].map(parseMapRange))

proc partOne(almanac: Almanac): string =
  var minLocation = high(int)

  for seed in almanac.seeds:
    var lookup = seed
    for mapping in almanac.mappings:
      var match = none(int)
      for range in mapping.ranges:
        if lookup >= range.srcStart and lookup < range.srcStart + range.rangeLen:
          match = some(range.destStart + lookup - range.srcStart)
          break
      lookup = match.get(lookup)

    if lookup < minLocation:
      minLocation = lookup
  $minLocation

proc partTwo(almanac: Almanac): string =
  var minLocation = high(int)

  for seedRange in almanac.seeds.distribute(almanac.seeds.len div 2, false):
    # super naive and silly, but works in 18 minutes so... 🤷
    # optimization possibilities:
    #   I think we could do something where we calculate the range overlaps, and only figure out the bounds,
    #   because all the numbers in the middle are probably noise?
    #
    #   Maybe work backwards, starting from the first location and increment until you find a valid location?
    #   The solution was only in the millions, so this seems way faster than looping over the actual ranges.
    #   But this only works because I already know the solution is low.
    for seed in seedRange[0]..<(seedRange[0]+seedRange[1]):
      var lookup = seed
      for mapping in almanac.mappings:
        var match = none(int)
        for range in mapping.ranges:
          if lookup >= range.srcStart and lookup < range.srcStart + range.rangeLen:
            match = some(range.destStart + lookup - range.srcStart)
            break
        lookup = match.get(lookup)

      if lookup < minLocation:
        minLocation = lookup
  $minLocation

proc findRanges(ranges: var seq[tuple[a, b: int]], mapping: Mapping): seq[tuple[a, b: int]] =
  result = newSeq[tuple[a, b: int]]()

  for mappingRange in mapping.ranges:
    let
      sa = mappingRange.srcStart
      sb = mappingRange.srcStart + mappingRange.rangeLen
      offset = mappingRange.destStart - mappingRange.srcStart

    var nextRanges = newSeq[tuple[a, b: int]]()

    while ranges.len > 0:
      let range = ranges.pop()

      let
        before = (a: range.a, b: min(sa, range.b))
        middle = (a: max(range.a, sa), b: min(range.b, sb))
        after = (a: max(sb, range.a), b: range.b)

      if before.a < before.b:
        nextRanges.add(before)
      if after.a < after.b:
        nextRanges.add(after)
      if middle.a < middle.b:
        result.add((middle.a  + offset, middle.b + offset))
    ranges = nextRanges
  result = result.concat(ranges)


proc partTwoOptimized(almanac: Almanac): string =
  var minLocation = high(int)

  for seedRange in almanac.seeds.distribute(almanac.seeds.len div 2, false):
    var ranges = newSeq[tuple[a, b: int]]()
    ranges.add((seedRange[0], seedRange[0] + seedRange[1]))

    for mapping in almanac.mappings:
      ranges = findRanges(ranges, mapping)

    for range in ranges:
      if range.a < minLocation:
        minLocation = range.a

  $minLocation

when isMainModule:
  echo "### DAY 05 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwoOptimized(parsed)):
    let
      parts = input.strip.split("\n\n")
      parsed = (seeds: parts[0].replace("seeds: ", "").splitWhitespace.map(parseInt), mappings: parts[1..<parts.len].map(parseMapping))
