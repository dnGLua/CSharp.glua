if CLIENT then
  local sound_PlayURL, sound_PlayFile
  if _G.__STARFALL__ then
    sound_PlayURL = bass.loadURL
    sound_PlayFile = bass.loadFile
  else
    sound_PlayURL = sound.PlayURL
    sound_PlayFile = sound.PlayFile
  end
  _G.bass = _G.bass or _G.sound -- relies on GLuaCompat
  bass.PlayURL = sound_PlayURL
  bass.PlayURL1 = sound_PlayURL
  bass.PlayURL2 = sound_PlayURL
  sound.PlayFile = sound_PlayFile
  sound.PlayFile1 = sound_PlayFile
  sound.PlayFile2 = sound_PlayFile
end

--[[
do
  -- Operator "fix" for Angle & Vector
  local CommonOps = {
    ["get"] = function(self, index) return self[index] end;
    ["set"] = function(self, index, value) self[index] = value end;
    ["op_Equality"] = function(self, other) return self == other end;
    ["op_Inequality"] = function(self, other) return self ~= other end;
    ["op_Addition"] = function(self, other) return self + other end;
    ["op_Subtraction"] = function(self, other) return self - other end;
    ["op_Multiply"] = function(self, other) return self * other end;
    ["op_Multiply1"] = function(self, other) return self * other end;
    ["op_Multiply2"] = function(self, other) return self * other end;
    ["op_Division"] = function(self, other) return self / other end;
    ["op_Division1"] = function(self, other) return self / other end;
    ["op_Division2"] = function(self, other) return self / other end;
    ["op_LogicalNot"] = function(self) return not self end;
    ["op_UnaryNegation"] = function(self) return -self end;
  }

  local real_Angle = _G.Angle
  _G.Angle = _G.setmetatable({}, {
    __call = function(_, x, y, z) return real_Angle(x, y, z) end;
    __index = CommonOps;
  })
  if _G.__STARFALL__ then
    local ANGLE = _G.getMethods("Angle")
    ANGLE.get = CommonOps.get
    ANGLE.set = CommonOps.set
  end

  local real_Vector = _G.Vector
  _G.Vector = _G.setmetatable({}, {
    __call = function(_, x, y, z) return real_Vector(x, y, z) end;
    __index = CommonOps;
  })
  if _G.__STARFALL__ then
    local VECTOR = _G.getMethods("Vector")
    VECTOR.get = CommonOps.get
    VECTOR.set = CommonOps.set
  end
end
--]]

if _G.__STARFALL__ then
  local MetaProperties = { -- relies on CSharpCompat (use uppercase-first)
    ["Entity"] = {
      ["get"] = {
        "IsValid";
        "IsValidPhys";
        "IsPlayer";
        "IsVehicle";
        "IsWeapon";
        "IsOnFire";
        "IsOnGround";
        "IsPlayerHolding"; -- SERVER
        "IsWeldedTo"; -- SERVER
        "EntIndex";
        "Health";
        "MaxHealth";
        "Color";
        "Pos";
        "Angles";
        "EyePos";
        "EyeAngles";
        "Velocity";
        "Parent";
        "Material";
        "Forward";
        "Right";
        "CreationTime";
        "CollisionGroup";
        "Persistent";
        -- SERVER
        "LinkedComponents";
        "Wirelink";
        "Owner";
      };
      ["set"] = {
        "Color";
        "Pos";
        "Angles";
        "Velocity";
        "Parent";
        "Material";
        "CollisionGroup";
        "Persistent";
      };
    };
    ["Player"] = {
      ["get"] = {
        "IsAlive";
        "IsBot";
        "IsNPC";
        "IsConnected";
        "IsAdmin";
        "IsSuperAdmin";
        "IsCrouching";
        "IsSprinting";
        "IsFrozen";
        "IsNoclipped";
        "IsFlashlightOn";
        "IsTyping";
        "InVehicle";
        "HasGodMode";
        "Armor";
        "MaxArmor";
        "Team";
        "Deaths";
        "Frags";
        "ActiveWeapon";
        "AimVector";
        "FOV";
        "JumpPower";
        "MaxSpeed";
        "RunSpeed";
        "ShootPos";
        "Vehicle";
        "Ping";
        "UserID";
        "SteamID";
        "SteamID64";
        "Name";
        "EyeTrace";
        "ViewEntity";
        "ViewModel";
        "Weapons";
        "GroundEntity";
        "AmmoCount";
        -- CLIENT
        "IsMuted";
        "IsSpeaking";
        "VoiceVolume";
        "FriendStatus";
      };
    };
  }
  local getStarfallTypes = _G.getStarfallTypes
  for typeName, tbl in next, MetaProperties do
    local methodTable = getStarfallTypes[typeName]
    local t = tbl.get
    if t then
      for _, name in next, t do
        local newName = "get" .. name
        methodTable[newName] = methodTable[newName] or methodTable[name]
      end
    end
    t = tbl.set
    if t then
      for _, name in next, t do
        local newName = "set" .. name
        methodTable[newName] = methodTable[newName] or methodTable[name]
      end
    end
  end
end

_G.__Angle, _G.__Vector = _G.Angle, _G.Vector
_G.Angle, _G.Vector = nil
_G.__EmptyTableCreate = function()
  return {}
end
_G.__TraceCreate = function(start, endpos, filter, mask, collisiongroup, ignoreworld, output)
  return {["start"]=start, ["endpos"]=endpos, ["filter"]=filter, ["mask"]=mask, ["collisiongroup"]=collisiongroup, ["ignoreworld"]=ignoreworld, ["output"]=output}
end
_G.__HullTraceCreate = function(start, endpos, maxs, mins, filter, mask, collisiongroup, ignoreworld, output)
  return {["start"]=start, ["endpos"]=endpos, ["maxs"]=maxs, ["mins"]=mins, ["filter"]=filter, ["mask"]=mask, ["collisiongroup"]=collisiongroup, ["ignoreworld"]=ignoreworld, ["output"]=output}
end
_G.__CamDataCreate = function(origin, angles, fov, znear, zfar, drawviewer, ortho)
  return {["origin"]=origin, ["angles"]=angles, ["fov"]=fov, ["znear"]=znear, ["zfar"]=zfar, ["drawviewer"]=drawviewer, ["ortho"]=ortho}
end
_G.__CamData_OrthoCreate = function(left, right, bottom, top)
  return {["left"]=left, ["right"]=right, ["bottom"]=bottom, ["top"]=top}
end
_G.__RenderCamDataCreate = function(x, y, w, h, type, origin, angles, fov, aspect, zfar, znear, subrect, bloomtone, offcenter, ortho)
  return {["x"]=x, ["y"]=y, ["w"]=w, ["h"]=h, ["type"]=type, ["origin"]=origin, ["angles"]=angles, ["fov"]=fov, ["aspect"]=aspect, ["zfar"]=zfar, ["znear"]=znear, ["subrect"]=subrect, ["bloomtone"]=bloomtone, ["offcenter"]=offcenter, ["ortho"]=ortho}
end
_G.__RenderCamData_RectCreate = _G.__CamData_OrthoCreate
_G.__ColorModifyCreate = function(addr, addg, addb, brightness, colour, contrast, mulr, mulg, mulb)
  return {["addr"]=addr, ["addg"]=addg, ["addb"]=addb, ["brightness"]=brightness, ["colour"]=colour, ["contrast"]=contrast, ["mulr"]=mulr, ["mulg"]=mulg, ["mulb"]=mulb}
end
_G.__VertexCreate = function(x, y, u, v)
  return {["x"]=x, ["y"]=y, ["u"]=u, ["v"]=v}
end
