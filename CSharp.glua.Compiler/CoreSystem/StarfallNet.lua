local net = _G.net
if _G.__STARFALL__ and net and not net.HasOOP then
  local assert, type = _G.assert, _G.type
  local isbool = _G.isbool or function(v) return type(v) == "boolean" end
  local isstring = _G.isstring or function(v) return type(v) == "string" end
  local pcall = _G.pcall
  local net_isStreaming = net.isStreaming
  local net_getBitsLeft = net.getBitsLeft
  local real_net_start = net.start
  local real_net_send = net.send
  local NetIsBusy, NetIsUnreliable = false, false
  local function net_IsBusy()
    return NetIsBusy or net_isStreaming() or net_getBitsLeft() <= 0
  end
  net.IsBusy = net_IsBusy
  function net.start(messageName, unreliable, ...)
    assert(isstring(messageName) and (unreliable == nil or isbool(unreliable)))
    if net_IsBusy() then return false end
    local ok = pcall(real_net_start, messageName, ...)
    if ok then
      NetIsUnreliable, NetIsBusy = unreliable, true
    end
    return ok
  end
  local function net_send(target, ...)
    if not NetIsBusy then return false end
    local ok = pcall(real_net_send, target, NetIsUnreliable or false, ...)
    --if ok then
    NetIsBusy, NetIsUnreliable = false
    --end
    return ok
  end
  net.send = net_send
  net.HasOOP = true
end -- Starfall net patch
