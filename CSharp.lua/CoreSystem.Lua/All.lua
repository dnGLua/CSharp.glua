
return function(dir, conf)
  dir = (dir and #dir > 0) and (dir .. ".CoreSystem.") or "CoreSystem."
  local require = require
  local load = function(module) return require(dir .. module) end
  
  --load("Natives")
  load("StarfallCompat")
  load("IsType")
  load("CSharpCompat")
  load("HookEx")
  load("StarfallNet")
  load("GLuaCompat")
  load("WireEx")
  load("Core")(conf)
  load("CoreExLib")
  load("Interfaces")
  load("Exception")
  load("Number")
  load("Char")
  load("String")
  load("Boolean")
  load("Delegate")
  load("Enum")
  --load("TimeSpan")
  --load("DateTime")
  load("Collections.EqualityComparer")
  load("Array")
  load("Type")
  --load("Collections.List")
  --load("Collections.Dictionary")
  --load("Collections.Queue")
  --load("Collections.Stack")
  --load("Collections.HashSet")
  --load("Collections.LinkedList")
  --load("Collections.Linq")
  --load("Convert")
  load("Math")
  --load("Random")
  --load("Text.StringBuilder")
  load("Console")
  --load("IO.File")
  --load("Reflection.Assembly")
  --load("Threading.Timer")
  --load("Threading.Thread")
  --load("Threading.Task")
  --[[load("Utilities")
  load("Globalization.Globalization")
  load("Numerics.HashCodeHelper")
  load("Numerics.Complex")
  load("Numerics.Matrix3x2")
  load("Numerics.Matrix4x4")
  load("Numerics.Plane")
  load("Numerics.Quaternion")
  load("Numerics.Vector2")
  load("Numerics.Vector3")
  load("Numerics.Vector4")]]
end
