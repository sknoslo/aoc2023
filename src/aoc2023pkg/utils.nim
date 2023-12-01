import
  strutils

# utility function to read input sans carriage returns
proc readInput*(file: File): string =
  file.readAll.replace("\r", "")
