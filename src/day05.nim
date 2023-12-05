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

when isMainModule:
  echo "### DAY 05 ###"

  let input = stdin.readInput

  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(parsed), partTwo(parsed)):
    let
      parts = input.strip.split("\n\n")
      parsed = (seeds: parts[0].replace("seeds: ", "").splitWhitespace.map(parseInt), mappings: parts[1..<parts.len].map(parseMapping))
