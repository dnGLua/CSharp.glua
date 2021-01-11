local hook = _G.hook
if hook and not hook.HasOOP then
  local Add_method = _G.__STARFALL__ and "add" or "Add"
  local real_hook_Add = hook[Add_method]
  local type = _G.type
  local isfunction = _G.isfunction or function(v) return type(v) == "function" end
  -- Custom `hook.Add` detour for OOP support
  hook[Add_method] = function(eventName, hookId, source)
    if not isfunction(source) then
      local __EventObject = source
      local __EventFunction = __EventObject.Function
      source = function(...)
        -- Pass the captured 'this' object as the first argument
        return __EventFunction(__EventObject, ...)
      end
    end
    return real_hook_Add(eventName, hookId, source)
  end
  hook.HasOOP = true -- Indicate that we have installed the detour already
end -- Hook OOP
