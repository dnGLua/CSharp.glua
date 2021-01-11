if pcall(_G.getmetatable, "") then
  function _G.__String(value)
    return value
  end
else
  local assert = _G.assert
  assert(_G.debugGetInfo(1, "f").func == nil, "what is this magic?!")
  _G.__STARFALL__ = true

  local STRING_META = {}
  local real_getmetatable = _G.getmetatable
  local real_setmetatable = _G.setmetatable
  local real_type = _G.type
  local real_tostring = _G.tostring
  local real_next = _G.next
  local real_pairs = _G.pairs
  local real_ipairs = _G.ipairs
  local real_rawget = _G.rawget
  local real_select = _G.select
  local real_unpack = _G.unpack
  local string = _G.string
  local real_string_len = string.len
  local real_string_format = string.format
  function STRING_META:__index(key)
    local val = string[key]
    if real_type(val) == "function" then
      return function(this, ...)
        return val(tostring(this), ...)
      end
    end
    if real_type(key) == "number" then
      return self:sub(key, key)
    end
  end
  --function STRING_META:__len()
  --  print("string.__len")
  --  return #real_rawget(self, 0)
  --end
  function STRING_META:__tostring()
    return real_rawget(self, 0)
  end
  -- String wrapper method (a.k.a. String ctor/constructor)
  function _G.__String(value)
    assert(real_type(value) == "string")
    return real_setmetatable({[0]=value}, STRING_META)
  end
  -- Detouring global functions
  function _G.getmetatable(value)
    -- Pretend we have it  (-:
    local tp = real_type(value)
    if tp == "string" then
      return STRING_META
    end
    return real_getmetatable(value)
  end
  function _G.setmetatable(value, mtbl)
    local tp = real_type(value)
    if tp == "string" then
      -- Silently set it
      value = __String(value)
      mtbl = STRING_META
    elseif tp == "table" and real_getmetatable(value) == STRING_META then
      -- Must prevent change (or removal with nil)
      mtbl = STRING_META
    end
    return real_setmetatable(value, mtbl)
  end
  function _G.type(value)
    local tp = real_type(value)
    if tp == "table" and real_getmetatable(value) == STRING_META then
      return "string"
    end
    return tp
  end
  function _G.tostring(value)
    local tp = real_type(value)
    if tp == "string" then
      return value --__String(value)
    end
    if tp == "table" and real_getmetatable(value) == STRING_META then
      return real_rawget(value, 0)
    end
    return real_tostring(value)
  end
  function _G.select(index, ...)
    local value = real_select(index, ...)
    if real_type(index) == "number" and real_type(value) == "string" then
      return __String(value)
    end
    return value
  end
  function string.len(value)
    assert(type(value) == "string")
    if real_type(value) == "table" and real_getmetatable(value) == STRING_META then
      value = real_rawget(value, 0)
    end
    return real_string_len(value)
  end
  function string.format(fmt, ...)
    assert(type(fmt) == "string")
    fmt = tostring(fmt)
    local size, args = real_select("#", ...), {}
    for i = 1, size do
      local value = real_select(i, ...)
      if real_type(value) == "table" and real_getmetatable(value) == STRING_META then
        args[i] = real_rawget(value, 0)
      else
        args[i] = value
      end
    end
    return real_string_format(fmt, real_unpack(args, 1, size))
  end
end -- Starfall compat
