import
  std/math,
  std/deques,
  std/tables,
  std/options,
  std/sequtils,
  std/strutils,
  aoc2023pkg/benchmark,
  aoc2023pkg/utils

type
  Signal = enum
    sLow,
    sHigh
  ModuleKind = enum
    mkFlipFlop,
    mkConjunction,
    mkBroadcast,
    mkButton
  Module = ref ModuleObj
  ModuleObj = object
    label: string
    outputs: seq[string]
    case kind: ModuleKind
    of mkFlipFlop:
      on = false
    of mkConjunction:
      memory: Table[string, Signal]
    of mkBroadcast: discard
    of mkButton: discard
  Message = tuple
    sender: string
    signal: Signal
    targets: seq[string]

proc `$`(module: Module): string =
  if module.kind == mkConjunction:
    module.label & " -> " & $module.outputs & " " & $module.memory
  else:
    module.label & " -> " & $module.outputs

proc parseModule(input: string): Module =
  let
    parts = input.split(" -> ")
    id = parts[0]
    outputs = parts[1].split(", ")

  if id == "broadcaster":
    Module(label: id, outputs: outputs, kind: mkBroadcast)
  elif id.startsWith("%"):
    Module(label: id[1..^1], outputs: outputs, kind: mkFlipFlop)
  else:
    Module(label: id[1..^1], outputs: outputs, kind: mkConjunction)

proc press(module: Module): Option[Message] =
  case module.kind:
    of mkButton:
      some((module.label, sLow, module.outputs))
    else:
      none(Message)

proc receive(module: Module, sender: string, signal: Signal): Option[Message] =
  case module.kind:
    of mkConjunction:
      module.memory[sender] = signal
      var toSend = sLow
      for m in module.memory.values:
        if m == sLow:
          toSend = sHigh
      some((module.label, toSend, module.outputs))
    of mkFlipFlop:
      case signal:
        of sLow:
          module.on = not module.on
          let toSend = if module.on: sHigh else: sLow
          some((module.label, toSend, module.outputs))
        of sHigh:
          none(Message)
    of mkBroadcast:
      some((module.label, signal, module.outputs))
    else:
      none(Message)

proc parseInput(input: string): ref Table[string, Module] =
  let parsed = newTable[string, Module]()

  parsed["button"] = Module(label: "button", outputs: @["broadcaster"], kind: mkButton)

  for module in input.strip.splitLines.map(parseModule):
    parsed[module.label] = module

  for module in parsed.values:
    for output in module.outputs:
      if parsed.hasKey(output):
        let target = parsed[output]
        if target.kind == mkConjunction:
          target.memory[module.label] = sLow

  parsed

proc partOne(input: string): string =
  let network = input.parseInput
  var
    mq: Deque[Message]
    lowPulses = 0
    highPulses = 0

  for i in 1..1000:
    mq.addLast(press(network["button"]).unsafeGet)

    while mq.len > 0:
      let message = mq.popFirst
      for target in message.targets:
        if message.signal == sLow:
          lowPulses += 1
        else:
          highPulses += 1

        if network.hasKey(target):
          # "rx" is not available in my input. part2 twist?
          let nextMessage = network[target].receive(message.sender, message.signal)
          if nextMessage.isSome:
            mq.addLast(nextMessage.unsafeGet)

  $(highPulses * lowPulses)

proc partTwo(input: string): string =
  let network = input.parseInput
  var
    mq: Deque[Message]
    lowPulses = 0
    highPulses = 0
    rxSender: Module
    senderCycles: Table[string, int]

  for module in network.values:
    if module.outputs.contains("rx"):
      rxSender = module
      break

  doAssert rxSender.kind == mkConjunction

  for i in 1..10000:
    mq.addLast(press(network["button"]).unsafeGet)

    while mq.len > 0:
      let message = mq.popFirst
      for target in message.targets:
        if message.signal == sLow:
          lowPulses += 1
        else:
          highPulses += 1

        if network.hasKey(target):
          let nextMessage = network[target].receive(message.sender, message.signal)
          if nextMessage.isSome:
            mq.addLast(nextMessage.unsafeGet)
        elif target == "rx":
          for (k, v) in rxSender.memory.pairs:
            if v == sHigh and not senderCycles.hasKey(k):
              senderCycles[k] = i
          if senderCycles.len == rxSender.memory.len:
            return $senderCycles.values.toSeq.lcm

  "INCOMPLETE"

when isMainModule:
  echo "### DAY 20 ###"

  let input = stdin.readInput
  echo "### INPUT ###"
  echo input
  echo "###  END  ###"

  bench(partOne(input), partTwo(input)):
    # parsing to a mutable object network table, so we need each to have their own copy
    discard

