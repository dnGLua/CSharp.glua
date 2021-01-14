
local __CoreExLib = _G.__CoreExLib or {}
_G.__CoreExLib = __CoreExLib
local next = next

function __CoreExLib.ForEach(array, body)
    for _, _v in next, array do
        body(_v)
    end
end

function __CoreExLib.ForEachI(array, body)
    for _k, _v in next, array do
        body(_k, _v)
    end
end

function __CoreExLib.ForEach_Func(array, body)
    for _, _v in next, array do
        if not body(_v) then break end
    end
end

function __CoreExLib.ForEachI_Func(array, body)
    for _k, _v in next, array do
        if not body(_k, _v) then break end
    end
end
