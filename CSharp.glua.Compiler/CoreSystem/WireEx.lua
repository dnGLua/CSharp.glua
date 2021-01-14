if _G.__STARFALL__ and SERVER and wire and not wire.HasOOP then
  local this_chip, next, pcall, string_upper, table_remove, wire = _G.chip(), _G.next, _G.pcall, string.upper, table.remove, wire
  local wire_getInputs, wire_getOutputs = wire.getInputs, wire.getOutputs
  local wire_adjustInputs, wire_adjustOutputs = wire.adjustInputs, wire.adjustOutputs
  local ActiveInputs, ActiveOutputs = {}, {} -- [name] = {index,type}
  local InputNames, InputTypes, OutputNames, OutputTypes = {}, {}, {}, {}
  local function FixupTypeAlias(type)
    type = string_upper(type)
    return type == "NUMBER" and "NORMAL" or type
  end
  function wire.adjustInputs(names, types)
    --assert(#names == #types)
    -- Try to adjust inputs in a safe manner
    local ok = pcall(wire_adjustInputs, names, types)
    if not ok then return false end
    -- Fetch the adjusted inputs (do not use names/types due to reference modification attack)
    InputNames, InputTypes = wire_getInputs(this_chip) --names, types
    -- Update active inputs state (recreating a new table is faster than clearing an existing one)
    ActiveInputs = {} -- This is fine because it is a 'private' table, never exposed outside of this module
    for index, name in next, InputNames do
      ActiveInputs[name] = {index, InputTypes[index]}
    end
    return true
  end
  function wire.adjustOutputs(names, types)
    --assert(#names == #types)
    -- Try to adjust outputs in a safe manner
    local ok = pcall(wire_adjustOutputs, names, types)
    if not ok then return false end
    -- Fetch the adjusted outputs (do not use names/types due to reference modification attack)
    OutputNames, OutputTypes = wire_getOutputs(this_chip) --names, types
    -- Update active outputs state (recreating a new table is faster than clearing an existing one)
    ActiveOutputs = {} -- This is fine because it is a 'private' table, never exposed outside of this module
    for index, name in next, OutputNames do
      ActiveOutputs[name] = {index, OutputTypes[index]}
    end
    return true
  end
  function wire.addInput(name, type)
    if ActiveInputs[name] then return false end -- Bail out if the input already exists
    type = FixupTypeAlias(type)
    local inputNames, inputTypes = wire_getInputs(this_chip) -- Get current inputs
    -- Insert new inputs's name and type
    local index = #inputNames + 1
    inputNames[index] = name
    inputTypes[index] = type
    local ok = pcall(wire_adjustInputs, inputNames, inputTypes)
    if not ok then return false end -- Bail out if input could not be added
    -- Update the caches
    InputNames, InputTypes = inputNames, inputTypes
    ActiveInputs[name] = {index, type}
    return true
  end
  function wire.addOutput(name, type)
    if ActiveOutputs[name] then return false end -- Bail out if the output already exists
    type = FixupTypeAlias(type)
    local outputNames, outputTypes = wire_getOutputs(this_chip) -- Get current outputs
    -- Insert new output's name and type
    local index = #outputNames + 1
    outputNames[index] = name
    outputTypes[index] = type
    local ok = pcall(wire_adjustOutputs, outputNames, outputTypes)
    if not ok then return false end
    -- Update the caches
    OutputNames, OutputTypes = outputNames, outputTypes
    ActiveOutputs[name] = {index, type}
    return true
  end
  function wire.removeInput(name)
    local activeInput = ActiveInputs[name]
    if not activeInput then return false end -- Bail out if the input does not exist
    local index = activeInput[1]
    table_remove(InputNames, index)
    table_remove(InputTypes, index)
    local ok = pcall(wire_adjustInputs, InputNames, InputTypes) -- Just carry on without checking
    ActiveInputs[name] = nil
    return ok
  end
  function wire.removeOutput(name)
    local activeOutput = ActiveOutputs[name]
    if not activeOutput then return false end -- Bail out if the output does not exist
    local index = activeOutput[1]
    table_remove(OutputNames, index)
    table_remove(OutputTypes, index)
    local ok = pcall(wire_adjustOutputs, OutputNames, OutputTypes) -- Just carry on without checking
    ActiveOutputs[name] = nil
    return ok
  end
  function wire.getInputType(name)
    local activeInput = ActiveInputs[name]
    if activeInput then return activeInput[2] end
  end
  function wire.getOutputType(name)
    local activeOutput = ActiveOutputs[name]
    if activeOutput then return activeOutput[2] end
  end
  function wire.setInputType(name, type)
    local activeInput = ActiveInputs[name]
    if not activeInput then return false end -- Bail out if the input does not exist
    type = FixupTypeAlias(type)
    local index = activeInput[1]
    local oldType = InputTypes[index]
    InputTypes[index] = type
    local ok = pcall(wire_adjustInputs, InputNames, InputTypes)
    if ok then
      activeInput[2] = type -- Update the cache
    else
      InputTypes[index] = oldType -- Unwind the state
    end
    return ok
  end
  function wire.setOutputType(name, type)
    local activeOutput = ActiveOutputs[name]
    if not activeOutput then return false end -- Bail out if the output does not exist
    type = FixupTypeAlias(type)
    local index = activeOutput[1]
    local oldType = OutputTypes[index]
    OutputTypes[index] = type
    local ok = pcall(wire_adjustOutputs, OutputNames, OutputTypes)
    if ok then
      activeOutput[2] = type -- Update the cache
    else
      OutputTypes[index] = oldType -- Unwind the state
    end
    return ok
  end

  local this_wirelink = wire.getWirelink(this_chip) --wire.self()
  function wire.getOutput(name) return this_wirelink[name] end
  --function wire.setInput(name, value) this_wirelink[name] = value end

  local hook_run = hook.run
  local ports = wire.ports
  local PORTS_MT = _G.getmetatable(ports)
  local real_ports_newindex = PORTS_MT["__newindex"]
  assert(ports and PORTS_MT and real_ports_newindex)
  function PORTS_MT:__newindex(outputName, value)
    local activeOutput = ActiveOutputs[outputName]
    if not activeOutput then return end
    local shouldRun = hook_run("OutputChanging", outputName, value)
    if shouldRun == false then return end
    if pcall(real_ports_newindex, self, outputName, value) then
      activeOutput[3] = value
      hook_run("OutputChanged", outputName, value)
    end
  end
  function wire.getInput(name) return ports[name] end
  --[[function wire.getOutput(name)
    local activeOutput = ActiveOutputs[name]
    if activeOutput then return activeOutput[3] end
  end]]
  function wire.setOutput(name, value) ports[name] = value end

  wire.HasOOP = true
end -- Wire extended
