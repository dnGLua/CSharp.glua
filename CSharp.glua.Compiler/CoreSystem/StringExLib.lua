local strlib = _G.strlib or {}
_G.strlib = strlib

local System = _G.System
local arrayFromTable, SystemValueTuple, SystemString = System.arrayFromTable, System.ValueTuple, System.String

local SystemByte, string_byte = System.Byte, string.byte
function strlib.bytes(...) return arrayFromTable(string_byte(...), SystemByte) end

local string_explode = _G.__STARFALL__ and string.explode or string.Explode
function strlib.explode(...) return arrayFromTable(string_explode(...), SystemString) end

local string_find = string.find
function strlib.find(...) return SystemValueTuple(string_find(...)) end

local string_gsub = string.gsub
function strlib.gsub(...) return SystemValueTuple(string_gsub(...)) end

local string_match = string.match
function strlib.match(...) return arrayFromTable(string_match(...), SystemString) end
