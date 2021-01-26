if _G.__STARFALL__ then
local assert, isnumber, isstring, isfunction, IsColor = _G.assert, _G.isnumber, _G.isstring, _G.isfunction, _G.IsColor

-- <SHARED>
-- constants
_G.vector_origin = _G.Vector(0, 0, 0)
_G.angle_zero = _G.Angle(0, 0, 0)
local NULL = _G["NULL"]
if NULL == nil then
  local _entity = _G.entity
  if isfunction(_entity) then
    _G["Entity"] = function(entIndex) assert(isnumber(entIndex)) return _entity(entIndex) or NULL end
    NULL = _entity(-2)
    _G["NULL"] = NULL
  end
end
-- builtin
_G["CompileString"] = _G.loadstring or _G["CompileString"]
do
  local sounds = _G["sounds"]
  if sounds then
    _G["CreateSound"] = sounds.create or _G["CreateSound"]
  end
end
do
  local print = _G.print
  local HUD_PRINTCONSOLE = _G.HUD_PRINTCONSOLE or 2
  local printMessage = _G.printMessage or function(messageType, message) print(message) end
  _G["PrintMessage"] = printMessage
  _G["ErrorNoHalt"] = function(message) printMessage(HUD_PRINTCONSOLE, message) end
end
_G["include"] = _G.dofile or _G["include"] -- _G.require ?
_G["IsValid"] = _G.isValid or _G["IsValid"]
_G["LocalToWorld"] = _G.localToWorld or _G["LocalToWorld"]
_G["MsgN"] = _G.print or _G["MsgN"]
do
  local _player = _G.player
  if isfunction(_player) then
    if CLIENT then
      assert(_G["LocalPlayer"] == nil)
      local MyLocalPlayer = _player()
      _G["LocalPlayer"] = function() return MyLocalPlayer end
      _G["getLocalPlayer"] = _G["LocalPlayer"]
    end
    _G["Player"] = function(userID) assert(isnumber(userID)) return _player(userID) or NULL end
    local find_allPlayers = find.allPlayers
    local string_upper = string.upper
    local tostring = _G.tostring
    local player = {
      ["GetAll"] = function() return find_allPlayers() end;
      ["GetBots"] = function() return find_allPlayers(function(ply) return ply:isBot() end) end;
      --["GetByID"] = _G["Player"]; -- ply:getUserID(); -- This actually uses ConnectionID (EntIndex-1) instead of UserID which is a separate thing. (or does it?)
      ["GetBySteamID"] = function(steamID) assert(isstring(steamID)) steamID = string_upper(steamID) return find_allPlayers(function(ply) return ply:getSteamID() == steamID end)[1] or NULL end;
      ["GetBySteamID64"] = function(steamID64) assert(isstring(steamID64)) return find_allPlayers(function(ply) return ply:getSteamID64() == steamID64 end)[1] or NULL end;
      ["GetByUniqueID"] = function(uniqueID) uniqueID = tostring(uniqueID) return find_allPlayers(function(ply) return ply:getUniqueID() == uniqueID end)[1] or NULL end;
      ["GetCount"] = function() return #find_allPlayers() end;
      ["GetHumans"] = function() return find_allPlayers(function(ply) return not ply:isBot() end) end;
    }
    player["getAll"] = player["GetAll"]
    player["getBots"] = player["GetBots"]
    player["getCount"] = player["GetCount"]
    player["getHumans"] = player["GetHumans"]
    _G["player"] = setmetatable(player,
      {
        ["__call"] = function(_, ...) return _player(...) or NULL end;
        ["__index"] = player;
        ["__metatable"] = false;
      }
    )
  end
end
_G["PrintTable"] = _G.printTable or _G["PrintTable"]
_G["WorldToLocal"] = _G.worldToLocal or _G["WorldToLocal"]
-- builtin -> debug
do
  local debug = _G["debug"] or {}
  _G["debug"] = debug
  debug["getinfo"] = _G.debugGetInfo or debug["getinfo"]
  debug["getlocal"] = _G.debugGetLocal or debug["getlocal"]
end
-- builtin -> util
do
  local util = _G["util"] or {}
  _G["util"] = util
  util["CRC"] = _G.crc or util["CRC"]
  -- fastlz -> util
  do
    local fastlz = _G["fastlz"]
    if fastlz then
      util["Compress"] = fastlz.compress or util["Compress"]
      util["Decompress"] = fastlz.decompress or util["Decompress"]
    end
  end
  -- http -> util
  do
    local http = _G["http"]
    if http then
      util["Base64Decode"] = http.base64Decode or util["Base64Decode"]
      util["Base64Encode"] = http.base64Encode or util["Base64Encode"]
    end
  end
  -- json -> util
  do
    local json = _G["json"]
    if json then
      util["TableToJSON"] = json.encode or util["TableToJSON"]
      util["JSONToTable"] = json.decode or util["JSONToTable"]
    end
  end
  -- trace -> util
  do
    local trace = _G["trace"]
    if trace then
      util["PointContents"] = trace.pointContents or util["PointContents"]
      do
        local trace_traceHull = trace.traceHull
        util["TraceHull"] = trace_traceHull and function(t) return trace_traceHull(t.start, t.endpos, t.maxs, t.mins, t.filter, t.mask, t.collisiongroup, t.ignoreworld) end or util["TraceHull"]
      end
      do
        local trace_trace = trace.trace
        util["TraceLine"] = trace_trace and function(t) return trace_trace(t.start, t.endpos, t.filter, t.mask, t.collisiongroup, t.ignoreworld) end or util["TraceLine"]
      end
      util["IntersectRayWithOBB"] = trace.intersectRayWithOBB or util["IntersectRayWithOBB"]
      util["IntersectRayWithPlane"] = trace.intersectRayWithPlane or util["IntersectRayWithPlane"]
      util["Decal"] = trace.decal or util["Decal"]
    end
  end
end
-- coroutine
do
  local coroutine = _G["coroutine"]
  if coroutine then
    local pcall = _G.pcall
    local coroutine_resume = coroutine.resume
    coroutine["resume"] = coroutine_resume and function(...) return pcall(coroutine_resume, ...) end or coroutine["resume"]
  end
end
-- find -> ents
do
  local find = _G["find"] or {}
  if find then
    local ents = _G["ents"] or {}
    _G["ents"] = ents
    ents["GetByIndex"] = _G.entity or ents["GetByIndex"]
    ents["FindInBox"] = find.inBox or ents["FindInBox"]
    ents["FindInSphere"] = find.inSphere or ents["FindInSphere"]
    ents["FindInCone"] = find.inCone or ents["FindInCone"]
    ents["FindByClass"] = find.byClass or ents["FindByClass"]
    ents["FindByModel"] = find.byModel or ents["FindByModel"]
    ents["FindByName"] = find.byName or ents["FindByName"]
    ents["FindAlongRay"] = find.inRay or ents["FindAlongRay"]
    ents["FindInPVS"] = find.inPVS or ents["FindInPVS"]
    ents["GetAll"] = find.all or ents["GetAll"]
    ents["getAll"] = ents["GetAll"]
  end
end
-- game
do
  local game = _G["game"]
  if game then
    _G["GetHostName"] = game.getHostname or game["GetHostName"]
    game["GetMap"] = game.getMap or game["GetMap"]
    game["GetHostName"] = _G["GetHostName"]
    game["IsDedicated"] = game.isDedicated or game["IsDedicated"]
    game["IsLAN"] = game.isLan or game["IsLAN"]
    game["MaxPlayers"] = game.getMaxPlayers or game["MaxPlayers"]
    game["SinglePlayer"] = game.isSinglePlayer or game["SinglePlayer"]
    game["getHostName"] = game["GetHostName"]
    game["getIsDedicated"] = game["IsDedicated"]
    game["getIsLAN"] = game["IsLAN"]
    game["getMaxPlayers"] = game["MaxPlayers"]
    game["getSinglePlayer"] = game["SinglePlayer"]
    if CLIENT then
      -- Client-side
      game["getHasFocus"] = game["hasFocus"]
      do
        local game_getSunInfo = game.getSunInfo
        _G.util["GetSunInfo"] = game_getSunInfo and function() local direction,obstruction = game_getSunInfo() return {["direction"]=direction, ["obstruction"]=obstruction} end or _G.util["GetSunInfo"]
      end
    end
    -- game -> gmod
    do
      local gmod = _G["gmod"] or {}
      _G["gmod"] = gmod
      gmod["GetGamemode"] = game.getGamemode or gmod["GetGamemode"]
    end
  end
end
-- hook
do
  local hook = _G["hook"]
  if hook then
    hook["Add"] = hook.add or hook["Add"]
    hook["Call"] = hook.run or hook["Call"]
    hook["Remove"] = hook.remove or hook["Remove"]
    hook["Run"] = hook.run or hook["Run"]
  end
end
-- http
do
  local http = _G["http"]
  if http then
    http["Fetch"] = http.get or http["Fetch"]
    http["Post"] = http.post or http["Post"]
  end
end
-- math
do
  local math = _G["math"]
  if math then
    _G["Lerp"] = math.lerp or _G["Lerp"]
    _G["LerpAngle"] = math.lerpAngle or _G["LerpAngle"]
    _G["LerpVector"] = math.lerpVector or _G["LerpVector"]
    math["AngleDifference"] = math.angleDifference or math["AngleDifference"]
    math["Approach"] = math.approach or math["Approach"]
    math["ApproachAngle"] = math.approachAngle or math["ApproachAngle"]
    math["BinToInt"] = math.binToInt or math["BinToInt"]
    math["Clamp"] = math.clamp or math["Clamp"]
    math["Dist"] = math.dist or math["Dist"]
    math["Distance"] = math.distance or math["Distance"]
    math["EaseInOut"] = math.easeInOut or math["EaseInOut"]
    math["IntToBin"] = math.intToBin or math["IntToBin"]
    math["Max"] = math.max or math["Max"]
    math["Min"] = math.min or math["Min"]
    math["NormalizeAngle"] = math.normalizeAngle or math["NormalizeAngle"]
    math["Rand"] = math.rand or math["Rand"]
    math["Remap"] = math.remap or math["Remap"]
    math["Round"] = math.round or math["Round"]
    math["TimeFraction"] = math.timeFraction or math["TimeFraction"]
    math["Truncate"] = math.truncate or math["Truncate"]
    math["BSplinePoint"] = math.bSplinePoint or math["BSplinePoint"]
  end
end
-- net
do
  local net = _G["net"]
  if net then
    net["getIsStreaming"] = net.isStreaming or net["getIsStreaming"]
    net["ReadAngle"] = net.readAngle or net["ReadAngle"]
    net["ReadBit"] = net.readBit or net["ReadBit"]
    net["ReadBool"] = net.readBool or net["ReadBool"]
    net["ReadColor"] = net.readColor or net["ReadColor"]
    net["ReadData"] = net.readData or net["ReadData"]
    net["ReadDouble"] = net.readDouble or net["ReadDouble"]
    net["ReadEntity"] = net.readEntity or net["ReadEntity"]
    net["ReadFloat"] = net.readFloat or net["ReadFloat"]
    net["ReadInt"] = net.readInt or net["ReadInt"]
    net["ReadMatrix"] = net.readMatrix or net["ReadMatrix"]
    net["ReadStream"] = net.readStream or net["ReadStream"]
    net["ReadString"] = net.readString or net["ReadString"]
    net["ReadTable"] = net.readTable or net["ReadTable"]
    net["ReadType"] = net.readType or net["ReadType"]
    net["ReadUInt"] = net.readUInt or net["ReadUInt"]
    net["ReadVector"] = net.readVector or net["ReadVector"]
    net["Receive"] = net.receive or net["Receive"]
    do
      local net_send = net.send
      if isfunction(net_send) then
        if SERVER then
          -- Server-side
          --local player_GetAll = find.allPlayers
          net["Broadcast"] = net.broadcast or net_send --function() return net_send(--[[player_GetAll()]]nil, false) end
          net["Send"] = net_send
        elseif CLIENT then
          -- Client-side
          local net_SendToServer = net.SendToServer or net.sendToServer or net_send --function() return net_send(nil, false) end
          net["sendToServer"] = net_SendToServer
          net["SendToServer"] = net_SendToServer
        end
      end
    end
    net["Start"] = net.start or net["Start"]
    net["WriteAngle"] = net.writeAngle or net["WriteAngle"]
    net["WriteBit"] = net.writeBit or net["WriteBit"]
    net["WriteBool"] = net.writeBool or net["WriteBool"]
    net["WriteColor"] = net.writeColor or net["WriteColor"]
    net["WriteData"] = net.writeData or net["WriteData"]
    net["WriteDouble"] = net.writeDouble or net["WriteDouble"]
    net["WriteEntity"] = net.writeEntity or net["WriteEntity"]
    net["WriteFloat"] = net.writeFloat or net["WriteFloat"]
    net["WriteInt"] = net.writeInt or net["WriteInt"]
    net["WriteMatrix"] = net.writeMatrix or net["WriteMatrix"]
    net["WriteStream"] = net.writeStream or net["WriteStream"]
    net["WriteString"] = net.writeString or net["WriteString"]
    net["WriteTable"] = net.writeTable or net["WriteTable"]
    net["WriteType"] = net.writeType or net["WriteType"]
    net["WriteUInt"] = net.writeUInt or net["WriteUInt"]
    net["WriteVector"] = net.writeVector or net["WriteVector"]
  end
end
-- string
do
  local string = _G["string"]
  if string then
    string["Explode"] = string.explode or string["Explode"]
    string["FromColor"] = string.fromColor or string["FromColor"]
    string["ToColor"] = string.toColor or string["ToColor"]
    string["Trim"] = string.trim or string["Trim"]
    -- string -> utf8
    do
      local utf8 = _G["utf8"] or {}
      _G["utf8"] = utf8
      utf8["char"] = string.utf8char or utf8["char"]
      utf8["codepoint"] = string.utf8codepoint or utf8["codepoint"]
      utf8["codes"] = string.utf8codes or utf8["codes"]
      utf8["force"] = string.utf8force or utf8["force"]
      utf8["len"] = string.utf8len or utf8["len"]
      utf8["offset"] = string.utf8offset or utf8["offset"]
    end
  end
end
-- team
do
  local team = _G["team"]
  if team then
    team["BestAutoJoinTeam"] = team.bestAutoJoinTeam or team["BestAutoJoinTeam"]
    team["GetAllTeams"] = team.getAllTeams or team["GetAllTeams"]
    team["GetColor"] = team.getColor or team["GetColor"]
    team["GetName"] = team.getName or team["GetName"]
    team["GetPlayers"] = team.getPlayers or team["GetPlayers"]
    team["GetScore"] = team.getScore or team["GetScore"]
    team["Joinable"] = team.getJoinable or team["Joinable"]
    team["NumPlayers"] = team.getNumPlayers or team["NumPlayers"]
    team["TotalDeaths"] = team.getNumDeaths or team["TotalDeaths"]
    team["TotalFrags"] = team.getNumFrags or team["TotalFrags"]
    team["Valid"] = team.exists or team["Valid"]
  end
end
-- timer
do
  local timer = _G["timer"]
  if timer then
    _G["CurTime"] = timer.curtime or _G["CurTime"]
    _G["FrameTime"] = timer.frametime or _G["FrameTime"]
    _G["RealTime"] = timer.realtime or _G["RealTime"]
    _G["SysTime"] = timer.systime or _G["SysTime"]
    timer["Create"] = timer.create or timer["Create"]
    timer["Simple"] = timer.simple or timer["Simple"]
    timer["Destroy"] = timer.remove or timer["Destroy"]
    timer["Remove"] = timer.remove or timer["Remove"]
    timer["Exists"] = timer.exists or timer["Exists"]
    timer["Stop"] = timer.stop or timer["Stop"]
    timer["Start"] = timer.start or timer["Start"]
    timer["Adjust"] = timer.adjust or timer["Adjust"]
    timer["Pause"] = timer.pause or timer["Pause"]
    timer["UnPause"] = timer.unpause or timer["UnPause"]
    timer["Toggle"] = timer.toggle or timer["Toggle"]
    timer["TimeLeft"] = timer.timeleft or timer["TimeLeft"]
    timer["RepsLeft"] = timer.repsleft or timer["RepsLeft"]
  end
end
-- physenv
do
  local physenv = _G["physenv"]
  if physenv then
    physenv["GetAirDensity"] = physenv.getAirDensity or physenv["GetAirDensity"]
    physenv["GetGravity"] = physenv.getGravity or physenv["GetGravity"]
    physenv["GetPerformanceSettings"] = physenv.getPerformanceSettings or physenv["GetPerformanceSettings"]
  end
end
-- table
do
  local table = _G["table"]
  if table then
    table["Add"] = table.add or table["Add"]
    table["ClearKeys"] = table.clearKeys or table["ClearKeys"]
    table["CollapseKeyValue"] = table.collapseKeyValue or table["CollapseKeyValue"]
    table["Copy"] = table.copy or table["Copy"]
    table["CopyFromTo"] = table.copyFromTo or table["CopyFromTo"]
    table["Count"] = table.count or table["Count"]
    table["Empty"] = table.empty or table["Empty"]
    table["FindNext"] = table.findNext or table["FindNext"]
    table["FindPrev"] = table.findPrev or table["FindPrev"]
    table["ForceInsert"] = table.forceInsert or table["ForceInsert"]
    table["ForEach"] = table.forEach or table["ForEach"]
    table["GetFirstKey"] = table.getFirstKey or table["GetFirstKey"]
    table["GetFirstValue"] = table.getFirstValue or table["GetFirstValue"]
    table["GetKeys"] = table.getKeys or table["GetKeys"]
    table["GetLastKey"] = table.getLastKey or table["GetLastKey"]
    table["GetLastValue"] = table.getLastValue or table["GetLastValue"]
    table["GetWinningKey"] = table.getWinningKey or table["GetWinningKey"]
    table["HasValue"] = table.hasValue or table["HasValue"]
    table["Inherit"] = table.inherit or table["Inherit"]
    table["IsSequential"] = table.isSequential or table["IsSequential"]
    table["KeyFromValue"] = table.keyFromValue or table["KeyFromValue"]
    table["KeysFromValue"] = table.keysFromValue or table["KeysFromValue"]
    table["LowerKeyNames"] = table.lowerKeyNames or table["LowerKeyNames"]
    table["Merge"] = table.merge or table["Merge"]
    table["Random"] = table.random or table["Random"]
    table["RemoveByValue"] = table.removeByValue or table["RemoveByValue"]
    table["Reverse"] = table.reverse or table["Reverse"]
    table["SortByKey"] = table.sortByKey or table["SortByKey"]
    table["SortByMember"] = table.sortByMember or table["SortByMember"]
    table["SortDesc"] = table.sortDesc or table["SortDesc"]
    table["ToString"] = table.toString or table["ToString"]
  end
end
-- </SHARED>

-- <SERVER-SIDE>
if SERVER then
  -- constraint
  do
    local constraint = _G["constraint"]
    if constraint then
      constraint["Weld"] = constraint.weld or constraint["Weld"]
      constraint["Axis"] = constraint.axis or constraint["Axis"]
      constraint["Ballsocket"] = constraint.ballsocket or constraint["Ballsocket"]
      constraint["AdvBallsocket"] = constraint.ballsocketadv or constraint["AdvBallsocket"]
      constraint["Elastic"] = constraint.elastic or constraint["Elastic"]
      constraint["Rope"] = constraint.rope or constraint["Rope"]
      constraint["Slider"] = constraint.slider or constraint["Slider"]
      constraint["NoCollide"] = constraint.nocollide or constraint["NoCollide"]
      constraint["RemoveAll"] = constraint.breakAll or constraint["RemoveAll"]
      constraint["RemoveConstraints"] = constraint.breakType or constraint["RemoveConstraints"]
      constraint["GetTable"] = constraint.getTable or constraint["GetTable"]
    end
  end
end
-- </SERVER-SIDE>

-- <CLIENT-SIDE>
if CLIENT then
  -- builtin
  _G["EyeAngles"] = _G.eyeAngles or _G["EyeAngles"]
  _G["EyePos"] = _G.eyePos or _G["EyePos"]
  _G["EyeVector"] = _G.eyeVector or _G["EyeVector"]
  _G["getEyeAngles"] = _G["EyeAngles"]
  _G["getEyePos"] = _G["EyePos"]
  _G["getEyeVector"] = _G["EyeVector"]
  _G["SetClipboardText"] = _G.setClipboardText or _G["SetClipboardText"]
  -- system
  do
    local system = _G["system"] or {}
    _G["system"] = system
    local SysTime = _G["SysTime"]
    system["AppTime"] = system["AppTime"] or function() return SysTime() end
    system["BatteryPower"] = system["BatteryPower"] or function() return 255 end
    system["FlashWindow"] = system["FlashWindow"] or function() end
    system["GetCountry"] = system["GetCountry"] or function() return "--" end
    system["HasFocus"] = game["hasFocus"] or function() return true end
    system["IsLinux"] = system["IsLinux"] or function() return false end
    system["IsOSX"] = system["IsOSX"] or function() return false end
    system["IsWindows"] = system["IsWindows"] or function() return true end
    system["IsWindowed"] = system["IsWindowed"] or function() return false end
    system["getHasFocus"] = system["HasFocus"]
  end
  -- bass -> sound
  do
    local bass = _G["bass"]
    if bass then
      local sound = _G["sound"] or _G["sounds"] or {}
      _G["sound"] = sound
      sound["PlayFile"] = bass.loadFile or sound["PlayFile"]
      sound["PlayURL"] = bass.loadURL or sound["PlayURL"]
    end
  end
  -- file
  do
    local file = _G["file"]
    if file then
      file["Open"] = file.open or file["Open"]
      file["Read"] = file.read or file["Read"]
      file["Write"] = file.write or file["Write"]
      file["Append"] = file.append or file["Append"]
      file["Exists"] = file.exists or file["Exists"]
      file["Delete"] = file.delete or file["Delete"]
      file["CreateDir"] = file.createDir or file["CreateDir"]
      file["Find"] = file.find or file["Find"] -- file.findInGame?
    end
  end
  -- input
  do
    local input = _G["input"]
    if input then
      input["LookupBinding"] = input.lookupBinding or input["LookupBinding"]
      input["IsKeyDown"] = input.isKeyDown or input["IsKeyDown"]
      input["GetKeyName"] = input.getKeyName or input["GetKeyName"]
      input["IsShiftDown"] = input.isShiftDown or input["IsShiftDown"]
      input["IsControlDown"] = input.isControlDown or input["IsControlDown"]
      input["GetCursorPos"] = input.getCursorPos or input["GetCursorPos"]
      -- input -> gui
      do
        local gui = _G["gui"] or {}
        _G["gui"] = gui
        gui["ScreenToVector"] = input.screenToVector or gui["ScreenToVector"]
        gui["EnableScreenClicker"] = input.enableCursor or gui["EnableScreenClicker"]
      end
    end
  end
  -- joystick
  do
    local joystick = _G["joystick"]
    if joystick then
      joystick["axis"] = joystick.getAxis or joystick["axis"]
      joystick["pov"] = joystick.getPov or joystick["pov"]
      joystick["button"] = joystick.getButton or joystick["button"]
      joystick["name"] = joystick.getName or joystick["name"]
      joystick["count"] = joystick.numJoysticks or joystick["count"]
    end
  end
  -- render
  do
    local render = _G["render"]
    if render then
      render["SetStencilEnable"] = render.setStencilEnable or render["SetStencilEnable"]
      render["ClearStencil"] = render.clearStencil or render["ClearStencil"]
      render["ClearBuffersObeyStencil"] = render.clearBuffersObeyStencil or render["ClearBuffersObeyStencil"]
      render["ClearStencilBufferRectangle"] = render.clearStencilBufferRectangle or render["ClearStencilBufferRectangle"]
      render["SetStencilCompareFunction"] = render.setStencilCompareFunction or render["SetStencilCompareFunction"]
      render["SetStencilFailOperation"] = render.setStencilFailOperation or render["SetStencilFailOperation"]
      render["SetStencilPassOperation"] = render.setStencilPassOperation or render["SetStencilPassOperation"]
      render["SetStencilZFailOperation"] = render.setStencilZFailOperation or render["SetStencilZFailOperation"]
      render["SetStencilReferenceValue"] = render.setStencilReferenceValue or render["SetStencilReferenceValue"]
      render["SetStencilTestMask"] = render.setStencilTestMask or render["SetStencilTestMask"]
      render["SetStencilWriteMask"] = render.setStencilWriteMask or render["SetStencilWriteMask"]
      render["PushFilterMag"] = render.setFilterMag or render["PushFilterMag"]
      render["PushFilterMin"] = render.setFilterMin or render["PushFilterMin"]
      render["Clear"] = render.clear or render["Clear"] -- FIXME: similar to unfix surface.SetDrawColor
      render["OverrideDepthEnable"] = render.enableDepth or render["OverrideDepthEnable"]
      render["ClearDepth"] = render.clearDepth or render["ClearDepth"]
      render["DrawSprite"] = render.draw3DSprite or render["DrawSprite"]
      render["DrawSphere"] = render.draw3DSphere or render["DrawSphere"]
      render["DrawWireframeSphere"] = render.draw3DWireframeSphere or render["DrawWireframeSphere"]
      render["DrawLine"] = render.draw3DLine or render["DrawLine"]
      render["DrawBox"] = render.draw3DBox or render["DrawBox"]
      render["DrawWireframeBox"] = render.draw3DWireframeBox or render["DrawWireframeBox"]
      render["DrawBeam"] = render.draw3DBeam or render["DrawBeam"]
      render["DrawQuad"] = render.draw3DQuad or render["DrawQuad"]
      render["CapturePixels"] = render.capturePixels or render["CapturePixels"]
      render["ReadPixel"] = render.readPixel or render["ReadPixel"]
      render["GetSurfaceColor"] = render.traceSurfaceColor or render["GetSurfaceColor"]
      render["ComputeLighting"] = render.computeLighting or render["ComputeLighting"]
      render["ComputeDynamicLighting"] = render.computeDynamicLighting or render["ComputeDynamicLighting"]
      render["GetLightColor"] = render.getLightColor or render["GetLightColor"]
      render["GetAmbientLightColor"] = render.getAmbientLightColor or render["GetAmbientLightColor"]
      render["FogMode"] = render.setFogMode or render["FogMode"]
      render["FogColor"] = render.setFogColor or render["FogColor"]
      render["FogMaxDensity"] = render.setFogDensity or render["FogMaxDensity"]
      render["FogStart"] = render.setFogStart or render["FogStart"]
      render["FogEnd"] = render.setFogEnd or render["FogEnd"]
      render["SetFogZ"] = render.setFogHeight or render["SetFogZ"]
      render["SupportsHDR"] = render.supportsHDR or render["SupportsHDR"]
      render["GetHDREnabled"] = render.getHDREnabled or render["GetHDREnabled"]
      render["SetLightingMode"] = render.setLightingMode or render["SetLightingMode"]
      -- render -> cam
      do
        local cam = _G["cam"] or {}
        _G["cam"] = cam
        cam["PopModelMatrix"] = render.popMatrix or cam["PopModelMatrix"]
      end
      -- render -> draw
      do
        local draw = _G["draw"] or {}
        _G["draw"] = draw
        draw["RoundedBox"] = render.drawRoundedBox or draw["RoundedBox"]
        draw["RoundedBoxEx"] = render.drawRoundedBoxEx or draw["RoundedBoxEx"]
        draw["DrawText"] = render.drawText or draw["DrawText"]
        draw["SimpleText"] = render.drawSimpleText or draw["SimpleText"]
      end
      -- render -> markup
      do
        local markup = _G["markup"] or {}
        _G["markup"] = markup
        markup["Parse"] = render.parseMarkup or markup["Parse"]
      end
      -- render -> surface
      do
        local surface = _G["surface"] or {}
        _G["surface"] = surface
        do
          local render_setColor, render_setRGBA = render.setColor, render.setRGBA
          local setColor = function(r, g, b, a)
            if isnumber(r) then return render_setRGBA(r, g, b, a) end
            if IsColor(r) then return render_setColor(r) end
          end
          if render_setColor or render_setRGBA then
            surface["SetDrawColor"] = setColor or surface["SetDrawColor"]
            surface["SetTextColor"] = setColor or surface["SetTextColor"]
          end
        end
        surface["GetTextureID"] = render.getTextureID or surface["GetTextureID"]
        surface["DrawRect"] = render.drawRectFast or surface["DrawRect"]
        surface["DrawOutlinedRect"] = render.drawRectOutline or surface["DrawOutlinedRect"]
        surface["DrawCircle"] = render.drawCircle or surface["DrawCircle"]
        surface["DrawTexturedRect"] = render.drawTexturedRectFast or surface["DrawTexturedRect"]
        surface["DrawTexturedRectUV"] = render.drawTexturedRectUVFast or surface["DrawTexturedRectUV"]
        surface["DrawTexturedRectRotated"] = render.drawTexturedRectRotatedFast or surface["DrawTexturedRectRotated"]
        surface["DrawLine"] = render.drawLine or surface["DrawLine"]
        surface["CreateFont"] = render.createFont or surface["CreateFont"]
        surface["GetTextSize"] = render.getTextSize or surface["GetTextSize"]
        surface["SetFont"] = render.setFont or surface["SetFont"]
        surface["SetMaterial"] = render.setMaterial or surface["SetMaterial"]
        surface["DrawPoly"] = render.drawPoly or surface["DrawPoly"]
      end
      -- ScrW / ScrH
      do
        local __FirstRun = true
        local pcall = _G.pcall
        local hook_run, timer_simple = hook.run, timer.simple
        local render_getGameResolution = render.getGameResolution
        local __CurrentResolutionW, __CurrentResolutionH, CheckClientGameResolution
        function CheckClientGameResolution()
          local ok, newWidth, newHeight = pcall(render_getGameResolution)
          if ok and (__CurrentResolutionW ~= newWidth or __CurrentResolutionH ~= newHeight) then
            if __FirstRun then
              __FirstRun = nil
            else
              hook_run("OnGameResolutionChanged", __CurrentResolutionW, __CurrentResolutionH)
            end
            __CurrentResolutionW, __CurrentResolutionH = newWidth, newHeight
          -- else print("failed -or- not changed")
          end
          return timer_simple(2, CheckClientGameResolution)
        end
        CheckClientGameResolution()
        function _G.ScrW() return __CurrentResolutionW or -1 end
        function _G.ScrH() return __CurrentResolutionH or -1 end
      end
    end
  end
end
-- </CLIENT-SIDE>

end -- GLua compat
