--!strict
local Decimal: any = require("../Decimal")
return function(cases: any, surface: any)
local failed, passed = 0, 0
local failures: { [string]: number } = {}
local function equalNumber(a: any, b: any): boolean
	if type(a) ~= "number" or type(b) ~= "number" then return false end
	if a == b or (a ~= a and b ~= b) then return true end
	if a == math.huge or a == -math.huge or b == math.huge or b == -math.huge then return false end
	return math.abs(a - b) <= 2e-11 * math.max(math.abs(a), math.abs(b))
end
local function display(x: any): string
	if type(x) == "table" and x.m ~= nil then return tostring(x.m) .. "e" .. tostring(x.e) end
	return string.sub(tostring(x), 1, 160)
end
local function check(ok: boolean, label: string, actual: any, expected: any)
	if ok then passed += 1 else
		failed += 1
		if failed <= 150 then print("FAIL", label, "got", display(actual), "expected", display(expected)) end
	end
end
for i, case in cases do
	local mode, method, args, kind, expected = table.unpack(case)
	local ok, actual = pcall(function(): any
		if mode == "instance" then
			local d = Decimal.new(args[1])
			return d[method](d, table.unpack(args, 2))
		end
		return Decimal[method](table.unpack(args))
	end)
	local matches = false
	if kind == "error" then matches = not ok
	elseif ok then
		if kind == "decimal" then
			if type(actual) == "table" then
				local sameExponent = actual.e == expected.e or (actual.e ~= actual.e and expected.e ~= expected.e)
				matches = sameExponent and equalNumber(actual.m, expected.m)
				-- libm log10 can put a near-power-of-ten mantissa on either side
				-- of a normalization boundary. Compare the represented value.
				if not matches and math.abs(actual.e - expected.e) == 1 then
					matches = equalNumber(actual.m * 10 ^ (actual.e - expected.e), expected.m)
				end
			end
		elseif kind == "number" then matches = equalNumber(actual, expected)
		else matches = actual == expected end
	end
	if not matches then failures[method] = (failures[method] or 0) + 1 end
	check(matches, tostring(i) .. " " .. mode .. " " .. method .. "(" .. display(args[1]) .. "," .. display(args[2]) .. ")", actual, expected)
end
local sample = Decimal.new(123)
for _, name in surface.instance do check(type(sample[name]) == "function", "instance API " .. name, type(sample[name]), "function") end
for _, name in surface.static do check(type(Decimal[name]) == "function", "static API " .. name, type(Decimal[name]), "function") end
for method, count in failures do print("Failures:", method, count) end
print("Reference:", passed, "passed;", failed, "failed")
assert(failed == 0, tostring(failed) .. " reference checks failed")

return { passed = passed, failed = failed }
end
