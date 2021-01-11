local select, type = _G.select, _G.type
local types = {
--["none"     ] = function(value) return (type(value) == "no value") end; -- absent
  ["none"     ] = function(...) return select("#", ...) == 0 end;
  ["nil"      ] = function(value) return ((value) == nil) end;
  ["boolean"  ] = function(value) return (((value) == false) or ((value) == true)) end;
  ["number"   ] = function(value) return (type((value)) == "number") end;
  ["string"   ] = function(value) return (type((value)) == "string") end;
  ["table"    ] = function(value) return (type((value)) == "table") end;
  ["thread"   ] = function(value) return (type((value)) == "thread") end; -- coroutine
  ["function" ] = function(value) return (type((value)) == "function") end;
  ["userdata" ] = function(value) return (type((value)) == "UserData") end; -- C
  ["entity"   ] = function(value)
    local tp = type((value))
    return ((tp == "Entity") or (tp == "Player") or (tp == "NPC") or (tp == "NextBot") or (tp == "Vehicle") or (tp == "Weapon"))
  end;
  ["angle"    ] = function(value)
    local tp = type((value))
    return ((tp == "Angle") or ((tp == "table") and (type(value.p) == "number") and (type(value.y) == "number") and (type(value.r) == "number")))
  end;
  ["vector"   ] = function(value)
    local tp = type((value))
    return ((tp == "Vector") or ((tp == "table") and (type(value.x) == "number") and (type(value.y) == "number") and (type(value.z) == "number")))
  end;
--["Color"    ] = function(value) return (type((value)) == "Color") end;
--["Player"   ] = function(value) return (type((value)) == "Player") end;
--["PhysObj"  ] -- Useless on clientside?
--["ConVar"   ]
--["File"     ]
--["Sound"    ] "CSoundPatch"
--["VMatrix"  ]
--["Material" ] "IMaterial"
--["Texture"  ] "ITexture"
}
types["bool"]   = types["boolean"]
types["Entity"] = types["entity"]
if CLIENT then
--["Bass"            ] "IGModAudioChannel"
--["CSEnt"           ]
--["DynamicLight"    ] "dlight_t"
--["Mesh"            ] "IMesh"
--["ProjectedTexture"] "ProjectedTexture"
--["Panel"           ]
--["MarkupObject"    ]
end
if _G.jit then
  types["proto"] = function(value) return (type((value)) == "proto") end
end
local inrange = function(n, min, max) return min <= n and n <= max end
_G["inrange"] = inrange
---[[
do
  types["Color"] = function(value)
    local tp = type((value))
    if tp == "Color" then return true end
    if tp == "table" then
      return (type(value.r) == "number")
         and (type(value.g) == "number")
         and (type(value.b) == "number")
         and (type(value.a) == "number")
         and inrange(value.r, 0x00, 0xFF)
         and inrange(value.g, 0x00, 0xFF)
         and inrange(value.b, 0x00, 0xFF)
         and inrange(value.a, 0x00, 0xFF)
    end
    return false
  end
  types["color"] = types["Color"]
end
--]]
for k, v in next, types do
  k = (string.sub(k, 1, 1) == string.upper(string.sub(k, 1, 1)) and "I" or "i") .. "s" .. k
  --if not _G[k] then _G[k] = v end
  _G[k] = v
end
