if _G.__STARFALL__ and not _G.__CSHARP__ then
  local assert, type = _G.assert, _G.type
  do
    local timer_getTimersLeft = timer.getTimersLeft
    function timer.getCanCreate() return timer_getTimersLeft() > 0 end
  end
  do
    local this_chip, this_owner = _G.chip(), _G.owner()
    _G.__ThisChipEntity = this_chip
    _G.__ThisOwnerPlayer = this_owner
    function _G.getChip() return this_chip end
    function _G.getOwner() return this_owner end
  end
  do
    local holograms, http, sounds = _G.holograms, _G.http, _G.sounds
    _G.Hologram = holograms.create
    holograms.getCanSpawn = holograms.canSpawn
    holograms.getHologramsLeft = holograms.hologramsLeft
    http.getCanRequest = http.canRequest
    sounds.getCanCreate = sounds.canCreate
    sounds.getSoundsLeft = sounds.soundsLeft
    assert(_G.sound == nil)
    _G.sound = sounds
  end
  if CLIENT then
    do
      local real_getName, real_setName = _G.getName, _G.setName
      assert(real_getName == nil)
      local tostring = _G.tostring
      local isstring = _G.isstring or function(v) return type(v) == "string" end
      local __CurrentName = _G.chip():getChipName() or ""
      function _G.getName() return __CurrentName end
      function _G.setName(name)
        assert(isstring(name))
        real_setName(name)
        __CurrentName = tostring(name)
      end
      real_setName(__CurrentName)
    end
    local pcall, bass, input, render = _G.pcall, _G.bass, _G.input, _G.render
    local bass_soundsLeft = bass.soundsLeft
    bass.getSoundsLeft = bass_soundsLeft
    bass.canCreate = bass.canCreate or function() return bass_soundsLeft() > 0 end
    bass.getCanCreate = bass.canCreate
    input.getCanLockControls = input.canLockControls
    local render_setHUDActive = render.setHUDActive
    function render.setHUDActive(active) return (pcall(render_setHUDActive, active)) end
  end
  if SERVER then
    if prop and not prop.getPropClean and not prop.getPropUndo then
      local isbool = _G.isbool or function(v) return type(v) == "boolean" end
      local prop = _G.prop
      prop.getCanSpawn = prop.canSpawn
      prop.getPropsLeft = prop.propsLeft
      prop.getSpawnRate = prop.spawnRate
      local real_prop_setPropClean = prop.setPropClean
      local real_prop_setPropUndo = prop.setPropUndo
      local current_propClean, current_propUndo = true, false
      prop.getPropClean = prop.getPropClean or function() return current_propClean end
      prop.getPropUndo = prop.getPropUndo or function() return current_propUndo end
      function prop.setPropClean(propClean)
        assert(isbool(propClean))
        local ret = real_prop_setPropClean(propClean)
        current_propClean = propClean
        return ret
      end
      function prop.setPropUndo(propUndo)
        assert(isbool(propUndo))
        local ret = real_prop_setPropUndo(propUndo)
        current_propUndo = propUndo
        return ret
      end
    end
    if wire then
      local wire = _G.wire
      local this_wirelink, this_server_UUID = wire.self(), wire.serverUUID()
      _G.__ThisSelfWirelink = this_wirelink
      _G.__ThisServerUUID = this_server_UUID
      function wire.getSelf() return this_wirelink end
      function wire.getServerUUID() return this_server_UUID end
      function wire.getPorts() return wire.ports end
    end
  end
  do
    -- Meta-tables
    --"^(is|in|can|has|get|set|enable|disable)([A-Z])"
    assert(_G.getStarfallTypes == nil)
    local getMethods = _G.getMethods
    _G.getStarfallTypes = {
      ["Entity"] = getMethods("Entity");
      ["Player"] = getMethods("Player");
      ["Sound"] = getMethods("Sound");
    }
    if CLIENT then
      getStarfallTypes["Bass"] = getMethods("Bass")
    end
    local table_copy, string_find, string_sub, string_upper = table.copy, string.find, string.sub, string.upper
    for typeName, sfType in next, getStarfallTypes do
      for key, value in next, table_copy(sfType) do
        --if type(value) == "function" then
          --if string_find(key, "^[gs]et[A-Z]") == nil then
        sfType[string_upper(string_sub(key, 1, 1)) .. string_sub(key, 2)] = value
          --end
        --end
      end
    end
  end
  _G.__CSHARP__ = true
end -- CSharp compat
