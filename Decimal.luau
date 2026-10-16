--!strict
-- break-infinity.js 2.1.1 port.
--[[
MIT License

Copyright (c) 2019 Timothy Stiles

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
-- Value = mantissa * 10^exponent. Arithmetic intentionally follows upstream.

-- Public structural types; dynamic dispatch is confined to implementation internals.
export type MantissaExponent = { mantissa: number, exponent: number }
export type DecimalSource = number | string | MantissaExponent
type DecimalData = {
	mantissa: number, exponent: number, m: number, e: number, s: number,
	setMantissaExponent: (self: Decimal, mantissa: number, exponent: number) -> (),
	setMantissaExponent_noNormalize: (self: Decimal, mantissa: number, exponent: number) -> (),
	copyFrom: (self: Decimal, value: MantissaExponent) -> (),
	clone: (self: Decimal) -> Decimal,
	setFromNumber_bypassCache: (self: Decimal, value: number) -> (),
	setFromNumber: (self: Decimal, value: number) -> (),
	setFromString_bypassCache: (self: Decimal, value: string) -> (),
	setFromString: (self: Decimal, value: string) -> Decimal,
	abs: (self: Decimal) -> Decimal,
	neg: (self: Decimal) -> Decimal,
	negate: (self: Decimal) -> Decimal,
	negated: (self: Decimal) -> Decimal,
	sgn: (self: Decimal) -> number,
	sign: (self: Decimal) -> number,
	round: (self: Decimal) -> Decimal,
	floor: (self: Decimal) -> Decimal,
	ceil: (self: Decimal) -> Decimal,
	trunc: (self: Decimal) -> Decimal,
	add: (self: Decimal, value: DecimalSource) -> Decimal,
	plus: (self: Decimal, value: DecimalSource) -> Decimal,
	sub: (self: Decimal, value: DecimalSource) -> Decimal,
	subtract: (self: Decimal, value: DecimalSource) -> Decimal,
	minus: (self: Decimal, value: DecimalSource) -> Decimal,
	mul: (self: Decimal, value: DecimalSource) -> Decimal,
	multiply: (self: Decimal, value: DecimalSource) -> Decimal,
	times: (self: Decimal, value: DecimalSource) -> Decimal,
	div: (self: Decimal, value: DecimalSource) -> Decimal,
	divide: (self: Decimal, value: DecimalSource) -> Decimal,
	divideBy: (self: Decimal, value: DecimalSource) -> Decimal,
	dividedBy: (self: Decimal, value: DecimalSource) -> Decimal,
	recip: (self: Decimal) -> Decimal,
	reciprocal: (self: Decimal) -> Decimal,
	reciprocate: (self: Decimal) -> Decimal,
	cmp: (self: Decimal, value: DecimalSource) -> number,
	compare: (self: Decimal, value: DecimalSource) -> number,
	eq: (self: Decimal, value: DecimalSource) -> boolean,
	equals: (self: Decimal, value: DecimalSource) -> boolean,
	neq: (self: Decimal, value: DecimalSource) -> boolean,
	notEquals: (self: Decimal, value: DecimalSource) -> boolean,
	lt: (self: Decimal, value: DecimalSource) -> boolean,
	lessThan: (self: Decimal, other: DecimalSource) -> boolean,
	lte: (self: Decimal, value: DecimalSource) -> boolean,
	lessThanOrEqualTo: (self: Decimal, other: DecimalSource) -> boolean,
	gt: (self: Decimal, value: DecimalSource) -> boolean,
	greaterThan: (self: Decimal, other: DecimalSource) -> boolean,
	gte: (self: Decimal, value: DecimalSource) -> boolean,
	greaterThanOrEqualTo: (self: Decimal, other: DecimalSource) -> boolean,
	max: (self: Decimal, value: DecimalSource) -> Decimal,
	min: (self: Decimal, value: DecimalSource) -> Decimal,
	clamp: (self: Decimal, min: DecimalSource, max: DecimalSource) -> Decimal,
	clampMin: (self: Decimal, min: DecimalSource) -> Decimal,
	clampMax: (self: Decimal, max: DecimalSource) -> Decimal,
	cmp_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> number,
	compare_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> number,
	eq_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	equals_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	neq_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	notEquals_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	lt_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	lte_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	gt_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	gte_tolerance: (self: Decimal, value: DecimalSource, tolerance: DecimalSource) -> boolean,
	log10: (self: Decimal) -> number,
	absLog10: (self: Decimal) -> number,
	pLog10: (self: Decimal) -> number,
	log: (self: Decimal, base: number) -> number,
	logarithm: (self: Decimal, base: number) -> number,
	log2: (self: Decimal) -> number,
	ln: (self: Decimal) -> number,
	pow: (self: Decimal, value: number | Decimal) -> Decimal,
	exp: (self: Decimal) -> Decimal,
	sqr: (self: Decimal) -> Decimal,
	sqrt: (self: Decimal) -> Decimal,
	cube: (self: Decimal) -> Decimal,
	cbrt: (self: Decimal) -> Decimal,
	dp: (self: Decimal) -> number,
	decimalPlaces: (self: Decimal) -> number,
	normalize: (self: Decimal) -> Decimal,
	toNumber: (self: Decimal) -> number,
	mantissaWithDecimalPlaces: (self: Decimal, places: number?) -> number,
	toString: (self: Decimal) -> string,
	toExponential: (self: Decimal, places: number?) -> string,
	toFixed: (self: Decimal, places: number?) -> string,
	toPrecision: (self: Decimal, places: number?) -> string,
	valueOf: (self: Decimal) -> string,
	toJSON: (self: Decimal) -> string,
	toStringWithDecimalPlaces: (self: Decimal, places: number?) -> string,
	pow_base: (self: Decimal, value: DecimalSource) -> Decimal,
	factorial: (self: Decimal) -> Decimal,
	sinh: (self: Decimal) -> Decimal,
	cosh: (self: Decimal) -> Decimal,
	tanh: (self: Decimal) -> Decimal,
	asinh: (self: Decimal) -> number,
	acosh: (self: Decimal) -> number,
	atanh: (self: Decimal) -> number,
	ascensionPenalty: (self: Decimal, ascensions: number) -> Decimal,
	egg: (self: Decimal) -> Decimal,
	isFinite: (self: Decimal) -> boolean,
	isNaN: (self: Decimal) -> boolean,
	isPositiveInfinity: (self: Decimal) -> boolean,
	isNegativeInfinity: (self: Decimal) -> boolean,
	fromMantissaExponent: (self: Decimal, mantissa: number, exponent: number) -> Decimal,
	fromMantissaExponent_noNormalize: (self: Decimal, mantissa: number, exponent: number) -> Decimal,
	fromNumber: (self: Decimal, value: number) -> Decimal,
	fromString: (self: Decimal, value: string) -> Decimal,
	fromDecimal: (self: Decimal, value: MantissaExponent) -> Decimal,
	fromValue: (self: Decimal, value: DecimalSource?) -> Decimal,
}
type DecimalMeta = {
	__add: (DecimalSource, DecimalSource) -> Decimal,
	__sub: (DecimalSource, DecimalSource) -> Decimal,
	__mul: (DecimalSource, DecimalSource) -> Decimal,
	__div: (DecimalSource, DecimalSource) -> Decimal,
	__pow: (DecimalSource, number | Decimal) -> Decimal,
	__unm: (Decimal) -> Decimal,
	__eq: (Decimal, Decimal) -> boolean,
	__lt: (Decimal, Decimal) -> boolean,
	__le: (Decimal, Decimal) -> boolean,
	__tostring: (Decimal) -> string,
}
export type Decimal = typeof(setmetatable({} :: DecimalData, {} :: DecimalMeta))
type DecimalClassData = {
	fromMantissaExponent: (mantissa: number, exponent: number) -> Decimal,
	fromMantissaExponent_noNormalize: (mantissa: number, exponent: number) -> Decimal,
	fromNumber_bypassCache: (value: number) -> Decimal,
	fromNumber: (value: number) -> Decimal,
	fromString_bypassCache: (value: string) -> Decimal,
	fromString: (value: string) -> Decimal,
	fromValue_noAlloc: (value: DecimalSource?) -> Decimal,
	abs: (value: DecimalSource) -> Decimal,
	neg: (value: DecimalSource) -> Decimal,
	negate: (value: DecimalSource) -> Decimal,
	negated: (value: DecimalSource) -> Decimal,
	sgn: (value: DecimalSource) -> number,
	sign: (value: DecimalSource) -> number,
	round: (value: DecimalSource) -> Decimal,
	floor: (value: DecimalSource) -> Decimal,
	ceil: (value: DecimalSource) -> Decimal,
	trunc: (value: DecimalSource) -> Decimal,
	add: (value: DecimalSource, other: DecimalSource) -> Decimal,
	plus: (value: DecimalSource, other: DecimalSource) -> Decimal,
	sub: (value: DecimalSource, other: DecimalSource) -> Decimal,
	subtract: (value: DecimalSource, other: DecimalSource) -> Decimal,
	minus: (value: DecimalSource, other: DecimalSource) -> Decimal,
	mul: (value: DecimalSource, other: DecimalSource) -> Decimal,
	multiply: (value: DecimalSource, other: DecimalSource) -> Decimal,
	times: (value: DecimalSource, other: DecimalSource) -> Decimal,
	div: (value: DecimalSource, other: DecimalSource) -> Decimal,
	divide: (value: DecimalSource, other: DecimalSource) -> Decimal,
	recip: (value: DecimalSource) -> Decimal,
	reciprocal: (value: DecimalSource) -> Decimal,
	reciprocate: (value: DecimalSource) -> Decimal,
	cmp: (value: DecimalSource, other: DecimalSource) -> number,
	compare: (value: DecimalSource, other: DecimalSource) -> number,
	eq: (value: DecimalSource, other: DecimalSource) -> boolean,
	equals: (value: DecimalSource, other: DecimalSource) -> boolean,
	neq: (value: DecimalSource, other: DecimalSource) -> boolean,
	notEquals: (value: DecimalSource, other: DecimalSource) -> boolean,
	lt: (value: DecimalSource, other: DecimalSource) -> boolean,
	lte: (value: DecimalSource, other: DecimalSource) -> boolean,
	gt: (value: DecimalSource, other: DecimalSource) -> boolean,
	gte: (value: DecimalSource, other: DecimalSource) -> boolean,
	max: (value: DecimalSource, other: DecimalSource) -> Decimal,
	min: (value: DecimalSource, other: DecimalSource) -> Decimal,
	clamp: (value: DecimalSource, min: DecimalSource, max: DecimalSource) -> Decimal,
	clampMin: (value: DecimalSource, min: DecimalSource) -> Decimal,
	clampMax: (value: DecimalSource, max: DecimalSource) -> Decimal,
	cmp_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> number,
	compare_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> number,
	eq_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	equals_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	neq_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	notEquals_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	lt_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	lte_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	gt_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	gte_tolerance: (value: DecimalSource, other: DecimalSource, tolerance: DecimalSource) -> boolean,
	log10: (value: DecimalSource) -> number,
	absLog10: (value: DecimalSource) -> number,
	pLog10: (value: DecimalSource) -> number,
	log: (value: DecimalSource, base: number) -> number,
	logarithm: (value: DecimalSource, base: number) -> number,
	log2: (value: DecimalSource) -> number,
	ln: (value: DecimalSource) -> number,
	pow10: (value: number) -> Decimal,
	pow: (value: DecimalSource, other: number | Decimal) -> Decimal,
	exp: (value: DecimalSource) -> Decimal,
	sqr: (value: DecimalSource) -> Decimal,
	sqrt: (value: DecimalSource) -> Decimal,
	cube: (value: DecimalSource) -> Decimal,
	cbrt: (value: DecimalSource) -> Decimal,
	dp: (value: DecimalSource) -> number,
	decimalPlaces: (value: DecimalSource) -> number,
	affordGeometricSeries: (resourcesAvailable: DecimalSource, priceStart: DecimalSource, priceRatio: DecimalSource, currentOwned: number | Decimal) -> Decimal,
	sumGeometricSeries: (numItems: number | Decimal, priceStart: DecimalSource, priceRatio: DecimalSource, currentOwned: number | Decimal) -> Decimal,
	affordArithmeticSeries: (resourcesAvailable: DecimalSource, priceStart: DecimalSource, priceAdd: DecimalSource, currentOwned: DecimalSource) -> Decimal,
	sumArithmeticSeries: (numItems: DecimalSource, priceStart: DecimalSource, priceAdd: DecimalSource, currentOwned: DecimalSource) -> Decimal,
	efficiencyOfPurchase: (cost: DecimalSource, currentRpS: DecimalSource, deltaRpS: DecimalSource) -> Decimal,
	randomDecimalForTesting: (absMaxExponent: number) -> Decimal,
	const: (value: number | string) -> Decimal,
	constant: (value: number | string) -> Decimal,
	fromDecimal: (value: MantissaExponent) -> Decimal,
	fromValue: (value: DecimalSource?) -> Decimal,
	new: (value: DecimalSource?) -> Decimal,
	ZERO: Decimal,
	ONE: Decimal,
	MINUS_ONE: Decimal,
	MAX_VALUE: Decimal,
	MIN_VALUE: Decimal,
	NUMBER_MAX_VALUE: Decimal,
	NUMBER_MIN_VALUE: Decimal,
	NaN: Decimal,
	POSITIVE_INFINITY: Decimal,
	NEGATIVE_INFINITY: Decimal,
}
export type DecimalClass = typeof(setmetatable({} :: DecimalClassData, {} :: { __call: (any, DecimalSource?) -> Decimal }))

local Decimal: any = {}
local methods: any = {}
local mt: any = {}
local NAN = 0 / 0
local EXP_LIMIT = 9e15
local pool: { [any]: any } = {}
local powers: { [number]: number } = {}
for e = -323, 308 do
	powers[e] = tonumber("1e" .. tostring(e)) :: number
end
local function powerOf10(e: number): number
	return powers[e] or NAN
end
local function finite(x: number): boolean
	return x == x and x ~= math.huge and x ~= -math.huge
end
local function trunc(x: number): number
	return if x < 0 then math.ceil(x) else math.floor(x)
end
-- JS Math.round ties toward +infinity, unlike Luau math.round for negatives.
local function round(x: number): number
	local lo = math.floor(x)
	return if x - lo >= 0.5 then lo + 1 else lo
end
local function sign(x: number): number
	if x ~= x then return NAN end
	return if x > 0 then 1 elseif x < 0 then -1 else x
end
local function integer(x: number): boolean
	return finite(x) and x == trunc(x)
end
-- Roblox can flush subnormal operands/literals to zero. Decode raw doubles
-- before comparing them, and keep the Decimal mantissa in the normal range.
local floatScratch = buffer.create(8)
local subnormalPool: { [number]: any } = {}
local subnormalPowers: { [number]: number } = {
	[-323] = 2,
	[-322] = 20,
	[-321] = 202,
	[-320] = 2024,
	[-319] = 20240,
	[-318] = 202402,
	[-317] = 2024023,
	[-316] = 20240225,
	[-315] = 202402253,
	[-314] = 2024022533,
	[-313] = 20240225331,
	[-312] = 202402253307,
	[-311] = 2024022533073,
	[-310] = 20240225330731,
	[-309] = 202402253307311,
	[-308] = 2024022533073106,
}
local function subnormalUnits(x: number): number?
	if math.abs(x) >= 2.2250738585072014e-308 then return nil end
	buffer.writef64(floatScratch, 0, x)
	local low = buffer.readu32(floatScratch, 0)
	local high = buffer.readu32(floatScratch, 4)
	if bit32.band(high, 0x7ff00000) ~= 0 then return nil end
	local units = bit32.band(high, 0xfffff) * 4294967296 + low
	if units == 0 then return nil end
	return if high >= 0x80000000 then -units else units
end
local function numberFromUnits(units: number): number
	if units == 0 then return 0 end
	local magnitude = math.abs(units)
	if magnitude >= 4503599627370496 then
		return units * 4.9406564584124654e-308 / 1e16
	end
	local high = math.floor(magnitude / 4294967296)
	local low = magnitude - high * 4294967296
	if units < 0 then high += 0x80000000 end
	buffer.writeu32(floatScratch, 0, low)
	buffer.writeu32(floatScratch, 4, high)
	return buffer.readf64(floatScratch, 0)
end
local function subnormalParts(units: number): (number, number)
	local e = math.floor(math.log10(math.abs(units)) - 323.3062153431158)
	local m: number
	if e == -324 then m = units * 5
	elseif subnormalPowers[e] then m = units / subnormalPowers[e]
	else m = units * 4.9406564584124654 * 10 ^ (-324 - e) end
	return m, e
end
-- IEEE multiplication rounds halfway subnormal results to an even integer.
local function roundUnits(x: number): number
	local magnitude = math.abs(x)
	local lo = math.floor(magnitude)
	local fraction = magnitude - lo
	local result = if fraction > 0.5 or fraction == 0.5 and lo % 2 ~= 0 then lo + 1 else lo
	return if x < 0 then -result else result
end

local function raw(m: number, e: number): any
	return setmetatable({ mantissa = m, exponent = e }, mt)
end
local function ME(m: number, e: number): any
	if not finite(m) or not finite(e) then return raw(NAN, 0) end
	return raw(m, e):normalize()
end
-- parseFloat accepts a numeric prefix and ignores trailing text, as in JS.
local function parseFloat(s: string): number
	s = string.match(s, "^%s*(.-)%s*$") :: string
	local inf = string.match(s, "^([+-]?)Infinity")
	if inf then return if inf == "-" then -math.huge else math.huge end
	local prefix = string.match(s, "^[+-]?%d*%.?%d+") or string.match(s, "^[+-]?%d+%.?")
	if not prefix then return NAN end
	local suffix = string.sub(s, #prefix + 1)
	-- A trailing decimal point belongs to the number, too.
	if not string.find(prefix, ".", 1, true) and string.sub(suffix, 1, 1) == "." then
		prefix ..= "."
		suffix = string.sub(suffix, 2)
	end
	local exp = string.match(suffix, "^[eE][+-]?%d+")
	return tonumber(prefix .. (exp or "")) or NAN
end
local function D(value: any): any
	if value == nil then return Decimal.ZERO end
	if type(value) == "table" and getmetatable(value) == mt then return value end
	if type(value) == "number" then return Decimal.fromNumber(value) end
	if type(value) == "string" then return Decimal.fromString(value) end
	if type(value) == "table" and type(value.mantissa) == "number" and type(value.exponent) == "number" then
		return ME(value.mantissa, value.exponent)
	end
	error("Unsupported Decimal source type.", 2)
end

function Decimal.new(value: any): any
	local result = raw(0, 0)
	if value == nil then return result end
	if type(value) == "number" then result:setFromNumber(value)
	elseif type(value) == "string" then result:setFromString(value)
	elseif type(value) == "table" and type(value.mantissa) == "number" and type(value.exponent) == "number" then
		result:copyFrom(value)
	else error("Unsupported Decimal source type.", 2) end
	return result
end
function methods.normalize(self: any): any
	if self.m >= 1 and self.m < 10 then return self end
	local units = subnormalUnits(self.m)
	if units then
		local m, e = subnormalParts(units)
		self.m = m; self.e += e
	end
	if self.m == 0 then self.m = 0; self.e = 0; return self end
	local e = math.floor(math.log10(math.abs(self.m)))
	self.m = if e == -324 then self.m * 10 / 1e-323 else self.m / powerOf10(e)
	self.e += e
	return self
end
function methods.setMantissaExponent(self: any, m: number, e: number)
	if not finite(m) or not finite(e) then self:copyFrom(Decimal.NaN); return end
	self.m = m; self.e = e; self:normalize()
end
function methods.setMantissaExponent_noNormalize(self: any, m: number, e: number)
	self.m = m; self.e = e
end
function methods.copyFrom(self: any, value: any)
	self.m = value.mantissa; self.e = value.exponent
end
function methods.clone(self: any): any return raw(self.m, self.e) end
function methods.setFromNumber_bypassCache(self: any, value: number)
	if not finite(value) then self:setMantissaExponent_noNormalize(value, 0); return end
	if subnormalUnits(value) then
		self.m = value; self.e = 0; self:normalize(); return
	end
	if value == 0 then self.m = 0; self.e = 0; return end
	self.e = math.floor(math.log10(math.abs(value)))
	self.m = if self.e == -324 then value * 10 / 1e-323 else value / powerOf10(self.e)
	self:normalize()
end
function methods.setFromNumber(self: any, value: number)
	local units = subnormalUnits(value)
	local cached = if units then subnormalPool[units] else pool[value]
	if cached then self:copyFrom(cached) else self:setFromNumber_bypassCache(value) end
end
function methods.setFromString_bypassCache(self: any, value: string)
	value = string.lower(value)
	local at = string.find(value, "e", 1, true)
	if at then
		self.m = parseFloat(string.sub(value, 1, at - 1))
		if self.m ~= self.m then self.m = 1 end
		local rest = string.sub(value, at + 1)
		local nextE = string.find(rest, "e", 1, true)
		self.e = parseFloat(if nextE then string.sub(rest, 1, nextE - 1) else rest)
		self:normalize(); return
	end
	if value == "nan" then self:copyFrom(Decimal.NaN); return end
	self:setFromNumber(parseFloat(value))
	if self:isNaN() then error("[DecimalError] Invalid argument: " .. value, 2) end
end
function methods.setFromString(self: any, value: string): any
	local cached = pool[value]
	if cached then self:copyFrom(cached) else self:setFromString_bypassCache(value) end
	return self
end
Decimal.fromMantissaExponent = ME
Decimal.fromMantissaExponent_noNormalize = raw
Decimal.fromValue_noAlloc = D
function Decimal.fromNumber_bypassCache(value: number): any
	local result = raw(0, 0); result:setFromNumber_bypassCache(value); return result
end
function Decimal.fromNumber(value: number): any
	local units = subnormalUnits(value)
	return (if units then subnormalPool[units] else pool[value]) or Decimal.fromNumber_bypassCache(value)
end
function Decimal.fromString_bypassCache(value: string): any
	local result = raw(0, 0); result:setFromString_bypassCache(value); return result
end
function Decimal.fromString(value: string): any return pool[value] or Decimal.fromString_bypassCache(value) end
function Decimal.constant(value: any): any
	assert(type(value) == "number" or type(value) == "string", "constant expects a number or string")
	-- NaN is not a valid Luau table key.
	if type(value) == "number" and value ~= value then return Decimal.NaN end
	if type(value) == "number" then
		local units = subnormalUnits(value)
		if units then
			if not subnormalPool[units] then subnormalPool[units] = table.freeze(Decimal.new(value)) end
			return subnormalPool[units]
		end
	end
	if not pool[value] then pool[value] = table.freeze(Decimal.new(value)) end
	return pool[value]
end
Decimal.const = Decimal.constant
function methods.fromMantissaExponent(self: any, m: number, e: number): any
	self:setMantissaExponent(m, e); return self
end
function methods.fromMantissaExponent_noNormalize(self: any, m: number, e: number): any
	self:setMantissaExponent_noNormalize(m, e); return self
end
function methods.fromNumber(self: any, value: number): any self:setFromNumber(value); return self end
function methods.fromString(self: any, value: string): any return self:setFromString(value) end
function methods.fromDecimal(self: any, value: any): any self:copyFrom(value); return self end
function methods.fromValue(self: any, value: any): any
	if value == nil then self:setFromNumber(0)
	elseif type(value) == "number" then self:setFromNumber(value)
	elseif type(value) == "string" then self:setFromString(value)
	elseif type(value) == "table" then self:copyFrom(value)
	else self:setFromNumber(0) end
	return self
end
function Decimal.fromDecimal(value: any): any return Decimal.new(value) end
function Decimal.fromValue(value: any): any return raw(0, 0):fromValue(value) end


function methods.abs(self: any): any return raw(math.abs(self.m), self.e) end
function methods.neg(self: any): any return raw(-self.m, self.e) end
function methods.sgn(self: any): number return sign(self.m) end
function methods.round(self: any): any
	if self.e < -1 then return Decimal.ZERO end
	if self.e < 17 then return Decimal.fromNumber(round(self:toNumber())) end
	return self
end
function methods.floor(self: any): any
	if not self:isFinite() then return self end
	if self.e < -1 then return if sign(self.m) >= 0 then Decimal.ZERO else Decimal.MINUS_ONE end
	if self.e < 17 then return Decimal.fromNumber(math.floor(self:toNumber())) end
	return self
end
function methods.ceil(self: any): any
	if self.e < -1 then return if sign(self.m) > 0 then Decimal.ONE else Decimal.ZERO end
	if self.e < 17 then return Decimal.fromNumber(math.ceil(self:toNumber())) end
	return self
end
function methods.trunc(self: any): any
	if self.e < 0 then return Decimal.ZERO end
	if self.e < 17 then return Decimal.fromNumber(trunc(self:toNumber())) end
	return self
end
function methods.add(self: any, value: any): any
	if not self:isFinite() then return self end
	local other = D(value)
	if not other:isFinite() then return other end
	if self.m == 0 then return other end
	if other.m == 0 then return self end
	local bigger, smaller = self, other
	if self.e < other.e then bigger, smaller = other, self end
	if bigger.e - smaller.e > 17 then return bigger end
	return ME(round(1e14 * bigger.m + 1e14 * smaller.m * powerOf10(smaller.e - bigger.e)), bigger.e - 14)
end
function methods.sub(self: any, value: any): any return self:add(D(value):neg()) end
function methods.mul(self: any, value: any): any
	if type(value) == "number" then
		local units = subnormalUnits(value)
		if units then
			local product = roundUnits(self.m * units)
			if product == 0 then return ME(0, self.e) end
			local m, e = subnormalParts(product)
			return ME(m, self.e + e)
		end
		if value < 1e307 and value > -1e307 then return ME(self.m * value, self.e) end
		return ME(self.m * 1e-307 * value, self.e + 307)
	end
	local other = D(value)
	return ME(self.m * other.m, self.e + other.e)
end
function methods.div(self: any, value: any): any return self:mul(D(value):recip()) end
function methods.recip(self: any): any return ME(1 / self.m, -self.e) end
local function compare(a: any, b: any): number
	if a.m == 0 then
		if b.m == 0 then return 0 elseif b.m < 0 then return 1 elseif b.m > 0 then return -1 end
	end
	if b.m == 0 then
		if a.m < 0 then return -1 elseif a.m > 0 then return 1 end
	end
	if a.m > 0 then
		if b.m < 0 then return 1 end
		if a.e > b.e then return 1 elseif a.e < b.e then return -1 end
		if a.m > b.m then return 1 elseif a.m < b.m then return -1 end
		return 0
	elseif a.m < 0 then
		if b.m > 0 then return -1 end
		if a.e > b.e then return -1 elseif a.e < b.e then return 1 end
		if a.m > b.m then return 1 elseif a.m < b.m then return -1 end
		return 0
	end
	error("Unreachable code")
end
function methods.cmp(self: any, value: any): number
	local other = D(value)
	if self:isNaN() then return if other:isNaN() then 0 else -1 end
	if other:isNaN() then return 1 end
	return compare(self, other)
end
function methods.eq(self: any, value: any): boolean
	local other = D(value); return self.e == other.e and self.m == other.m
end
function methods.neq(self: any, value: any): boolean return not self:eq(value) end
function methods.lt(self: any, value: any): boolean
	local other = D(value)
	if self.m == 0 then return other.m > 0 end
	if other.m == 0 then return self.m <= 0 end
	if self.e == other.e then return self.m < other.m end
	if self.m > 0 then return other.m > 0 and self.e < other.e end
	return other.m > 0 or self.e > other.e
end
function methods.gt(self: any, value: any): boolean
	local other = D(value)
	if self.m == 0 then return other.m < 0 end
	if other.m == 0 then return self.m > 0 end
	if self.e == other.e then return self.m > other.m end
	if self.m > 0 then return other.m < 0 or self.e > other.e end
	return other.m < 0 and self.e < other.e
end
function methods.lte(self: any, value: any): boolean return not self:gt(value) end
function methods.gte(self: any, value: any): boolean return not self:lt(value) end
function methods.lessThan(self: any, value: any): boolean
	local other = D(value); return not self:isNaN() and not other:isNaN() and compare(self, other) < 0
end
function methods.lessThanOrEqualTo(self: any, value: any): boolean
	local other = D(value); return not self:isNaN() and not other:isNaN() and compare(self, other) < 1
end
function methods.greaterThan(self: any, value: any): boolean
	local other = D(value); return not self:isNaN() and not other:isNaN() and compare(self, other) > 0
end
function methods.greaterThanOrEqualTo(self: any, value: any): boolean
	local other = D(value); return not self:isNaN() and not other:isNaN() and compare(self, other) > -1
end
function methods.max(self: any, value: any): any local d = D(value); return if self:lt(d) then d else self end
function methods.min(self: any, value: any): any local d = D(value); return if self:gt(d) then d else self end
function methods.clamp(self: any, low: any, high: any): any return self:max(low):min(high) end
methods.clampMin = methods.max
methods.clampMax = methods.min
function methods.eq_tolerance(self: any, value: any, tolerance: any): boolean
	local other = D(value)
	return self:sub(other):abs():lte(self:abs():max(other:abs()):mul(tolerance))
end
function methods.cmp_tolerance(self: any, value: any, tolerance: any): number
	local other = D(value); return if self:eq_tolerance(other, tolerance) then 0 else self:cmp(other)
end
function methods.neq_tolerance(self: any, value: any, tolerance: any): boolean return not self:eq_tolerance(value, tolerance) end
function methods.lt_tolerance(self: any, value: any, tolerance: any): boolean
	local other = D(value); return not self:eq_tolerance(other, tolerance) and self:lt(other)
end
function methods.lte_tolerance(self: any, value: any, tolerance: any): boolean
	local other = D(value); return self:eq_tolerance(other, tolerance) or self:lt(other)
end
function methods.gt_tolerance(self: any, value: any, tolerance: any): boolean
	local other = D(value); return not self:eq_tolerance(other, tolerance) and self:gt(other)
end
function methods.gte_tolerance(self: any, value: any, tolerance: any): boolean
	local other = D(value); return self:eq_tolerance(other, tolerance) or self:gt(other)
end
function methods.log10(self: any): number return self.e + math.log10(self.m) end
function methods.absLog10(self: any): number return self.e + math.log10(math.abs(self.m)) end
function methods.pLog10(self: any): number return if self.m <= 0 or self.e < 0 then 0 else self:log10() end
function methods.log(self: any, base: number): number return (math.log(10) / math.log(base)) * self:log10() end
function methods.log2(self: any): number return 3.321928094887362 * self:log10() end
function methods.ln(self: any): number return 2.302585092994045 * self:log10() end
function Decimal.pow10(value: number): any
	if integer(value) then return raw(1, value) end
	return ME(10 ^ math.fmod(value, 1), trunc(value))
end
function methods.pow(self: any, value: any): any
	if self.m == 0 then return self end
	local n = if type(value) == "number" then value else D(value):toNumber()
	if self.m < 0 and subnormalUnits(n) then return Decimal.NaN end
	local temp = self.e * n
	if integer(temp) and math.abs(temp) <= 9007199254740991 then
		local m = self.m ^ n
		if m == 0 and (self.m > 0 or integer(n)) then
			-- Recover a rounded native subnormal power without using subnormal
			-- operands in Studio's floating-point environment.
			local logarithm = n * math.log10(math.abs(self.m))
			if logarithm > -325 and logarithm < -307.6526555685888 then
				local units = roundUnits(10 ^ (logarithm + 323.3062153431158))
				if units > 0 then
					if self.m < 0 and math.abs(math.fmod(n, 2)) == 1 then units = -units end
					local mantissa, exponent = subnormalParts(units)
					return ME(mantissa, exponent + temp)
				end
			end
		end
		if finite(m) and m ~= 0 then return ME(m, temp) end
	end
	local e = trunc(temp)
	local m = 10 ^ (n * math.log10(self.m) + (temp - e))
	if finite(m) and m ~= 0 then return ME(m, e) end
	local result = Decimal.pow10(n * self:absLog10())
	if self:sgn() == -1 then
		local mod = math.abs(math.fmod(n, 2))
		if mod == 1 then return result:neg() elseif mod == 0 then return result end
		return Decimal.NaN
	end
	return result
end
function methods.exp(self: any): any
	local x = self:toNumber()
	if -706 < x and x < 709 then return Decimal.fromNumber(math.exp(x)) end
	return Decimal.pow(math.exp(1), x)
end
function methods.sqr(self: any): any return ME(self.m ^ 2, self.e * 2) end
function methods.sqrt(self: any): any
	if self.m < 0 then return Decimal.NaN end
	if self.e % 2 ~= 0 then return ME(math.sqrt(self.m) * 3.16227766016838, math.floor(self.e / 2)) end
	return ME(math.sqrt(self.m), math.floor(self.e / 2))
end
function methods.cube(self: any): any return ME(self.m ^ 3, self.e * 3) end
function methods.cbrt(self: any): any
	local m = sign(self.m) * math.abs(self.m) ^ (1 / 3)
	local mod = math.fmod(self.e, 3)
	if mod == 1 or mod == -2 then return ME(m * 2.154434690031883, math.floor(self.e / 3)) end
	if mod ~= 0 then return ME(m * 4.641588833612778, math.floor(self.e / 3)) end
	return ME(m, math.floor(self.e / 3))
end
function methods.dp(self: any): number
	if not self:isFinite() then return NAN end
	if self.e >= 17 then return 0 end
	local places, e = -self.e, 1
	while math.abs(round(self.m * e) / e - self.m) > 1e-10 do e *= 10; places += 1 end
	return if places > 0 then places else 0
end
function methods.toNumber(self: any): number
	if not self:isFinite() then return self.mantissa end
	if self.e > 308 then return if self.m > 0 then math.huge else -math.huge end
	if self.e < -324 then return 0 end
	if self.e == -324 then return numberFromUnits(if self.m > 0 then 1 else -1) end
	if subnormalPowers[self.e] then return numberFromUnits(roundUnits(self.m * subnormalPowers[self.e])) end
	local result = self.m * powerOf10(self.e)
	if not finite(result) or self.e < 0 then return result end
	local rounded = round(result)
	return if math.abs(rounded - result) < 1e-10 then rounded else result
end

-- Number formatting: Luau's shortest double conversion, with JS notation thresholds.
local function numberString(x: number): string
	if x ~= x then return "NaN" end
	if x == math.huge then return "Infinity" elseif x == -math.huge then return "-Infinity" end
	if x == 0 then return "0" end
	local s = tostring(x)
	local negative = string.sub(s, 1, 1) == "-"
	if negative then s = string.sub(s, 2) end
	local coefficient, expText = string.match(s, "^([^eE]+)[eE]([+-]?%d+)$")
	local exponent = tonumber(expText) or 0
	local c = coefficient or s
	local dot = string.find(c, ".", 1, true)
	local digits = string.gsub(c, "%.", "")
	local point = (dot and dot - 1 or #c) + exponent
	local leading = string.match(digits, "^0*") :: string
	digits = string.sub(digits, #leading + 1); point -= #leading
	digits = string.gsub(digits, "0+$", "")
	local result: string
	if point > 0 and point <= 21 then
		result = if #digits <= point then digits .. string.rep("0", point - #digits) else string.sub(digits, 1, point) .. "." .. string.sub(digits, point + 1)
	elseif point <= 0 and point > -6 then
		result = "0." .. string.rep("0", -point) .. digits
	else
		result = string.sub(digits, 1, 1) .. (if #digits > 1 then "." .. string.sub(digits, 2) else "") .. "e" .. (if point - 1 >= 0 then "+" else "") .. tostring(point - 1)
	end
	return (if negative then "-" else "") .. result
end
-- Exact finite binary64 expansion. This keeps JS toFixed rounding (including ties)
-- independent of libc printf's ties-to-even and precision limits.
local function multiplyDigits(s: string, factor: number): string
	local out: { string } = table.create(#s + 1) :: { string }
	local carry = 0
	for i = #s, 1, -1 do
		local n = (string.byte(s, i) - 48) * factor + carry
		out[i + 1] = string.char(48 + n % 10); carry = math.floor(n / 10)
	end
	out[1] = if carry > 0 then tostring(carry) else ""
	return table.concat(out)
end
local function exactDigits(x: number): (string, number)
	if x == 0 then return "0", 0 end
	local f, e = math.frexp(x)
	local digits = string.format("%.0f", f * 9007199254740992)
	e -= 53
	if e >= 0 then
		for _ = 1, e do digits = multiplyDigits(digits, 2) end
		return digits, 0
	end
	for _ = 1, -e do digits = multiplyDigits(digits, 5) end
	return digits, -e
end
local function roundedDigits(digits: string, keep: number): string
	if keep < 0 then return "0" end
	if keep >= #digits then return digits .. string.rep("0", keep - #digits) end
	local result = string.sub(digits, 1, keep)
	if string.byte(digits, keep + 1) >= 53 then
		local at = #result
		while at > 0 and string.sub(result, at, at) == "9" do at -= 1 end
		if at == 0 then result = "1" .. string.rep("0", #result)
		else result = string.sub(result, 1, at - 1) .. string.char(string.byte(result, at) + 1) .. string.rep("0", #result - at) end
	end
	return if result == "" then "0" else result
end
local function checkedPlaces(places: number?, default: number, minimum: number): number
	local n = if places == nil or places ~= places then default else trunc(places)
	assert(n >= minimum and n <= 100, "[DecimalError] precision out of range")
	return n
end
local function trailZeroes(places: number?): string
	if places == nil or not (places > 0) then return "" end
	assert(finite(places) and places <= 1000000, "[DecimalError] formatting output exceeds 1000000 zeroes")
	return "." .. string.rep("0", math.ceil(places))
end
local function fixedNumber(x: number, places: number): string
	if not finite(x) then return numberString(x) end
	if math.abs(x) >= 1e21 then return numberString(x) end
	local digits, scale = exactDigits(math.abs(x))
	local result = roundedDigits(digits, #digits - scale + places)
	if #result <= places then result = string.rep("0", places + 1 - #result) .. result end
	if places > 0 then result = string.sub(result, 1, #result - places) .. "." .. string.sub(result, #result - places + 1) end
	return (if x < 0 or (subnormalUnits(x) or 0) < 0 then "-" else "") .. result
end
local function exponentialNumber(x: number, places: number?): string
	if not finite(x) then return numberString(x) end
	local exponent: number
	local digits: string
	if places == nil then
		local s = numberString(math.abs(x))
		local c, e = string.match(s, "^([^e]+)e([+-]?%d+)$")
		if c then digits = string.gsub(c, "%.", ""); exponent = tonumber(e) :: number
		else
			local dot = string.find(s, ".", 1, true)
			digits = string.gsub(s, "%.", ""); exponent = (dot and dot - 1 or #s) - 1
			local leading = string.match(digits, "^0*") :: string
			digits = string.sub(digits, #leading + 1); exponent -= #leading
			digits = string.gsub(digits, "0+$", "")
		end
		if x == 0 then digits = "0"; exponent = 0 end
	else
		local scale: number
		digits, scale = exactDigits(math.abs(x)); exponent = if x == 0 then 0 else #digits - scale - 1
		local keep = places + 1
		digits = roundedDigits(digits, keep)
		if #digits > keep then exponent += 1; digits = string.sub(digits, 1, keep) end
	end
	return (if x < 0 then "-" else "") .. string.sub(digits, 1, 1) .. (if #digits > 1 then "." .. string.sub(digits, 2) else "") .. "e" .. (if exponent >= 0 then "+" else "") .. tostring(exponent)
end
function methods.mantissaWithDecimalPlaces(self: any, places: number?): number
	if not self:isFinite() then return self.m end
	if self.m == 0 then return 0 end
	local len = (places or NAN) + 1
	local digits = math.ceil(math.log10(math.abs(self.m)))
	local rounded = round(self.m * 10 ^ (len - digits)) * 10 ^ (digits - len)
	return parseFloat(fixedNumber(rounded, checkedPlaces(math.max(len - digits, 0), 0, 0)))
end
function methods.toString(self: any): string
	if not self:isFinite() then return numberString(self.m) end
	if self.e <= -EXP_LIMIT or self.m == 0 then return "0" end
	if self.e < 21 and self.e > -7 then return numberString(self:toNumber()) end
	return numberString(self.m) .. "e" .. (if self.e >= 0 then "+" else "") .. numberString(self.e)
end
function methods.toExponential(self: any, places: number?): string
	if not self:isFinite() then return numberString(self.m) end
	if self.e <= -EXP_LIMIT or self.m == 0 then
		return "0" .. trailZeroes(places) .. "e+0"
	end
	if self.e > -324 and self.e < 308 then
		return exponentialNumber(self:toNumber(), if places == nil then nil else checkedPlaces(places, 0, 0))
	end
	local p = if places == nil or not finite(places) then 17 else places
	local len = p + 1
	local digits = math.max(1, math.ceil(math.log10(math.abs(self.m))))
	local rounded = round(self.m * 10 ^ (len - digits)) * 10 ^ (digits - len)
	return fixedNumber(rounded, checkedPlaces(math.max(len - digits, 0), 0, 0)) .. "e" .. (if self.e >= 0 then "+" else "") .. numberString(self.e)
end
function methods.toFixed(self: any, places: number?): string
	if not self:isFinite() then return numberString(self.m) end
	if self.e <= -EXP_LIMIT or self.m == 0 then return "0" .. trailZeroes(places) end
	if self.e >= 17 then
		local m = string.gsub(numberString(self.m), "%.", "")
		-- Upstream counts the negative sign as part of the mantissa length.
		local zeroes = self.e - #m + 1
		assert(zeroes <= 1000000, "[DecimalError] toFixed output exceeds 1000000 zeroes; use toExponential")
		return m .. string.rep("0", math.max(0, zeroes)) .. trailZeroes(places)
	end
	return fixedNumber(self:toNumber(), checkedPlaces(places, 0, 0))
end
function methods.toPrecision(self: any, places: number?): string
	if places == nil then return self:toExponential(NAN) end -- matches upstream's undefined arithmetic
	if self.e <= -7 then return self:toExponential(places - 1) end
	if places > self.e then return self:toFixed(places - self.e - 1) end
	return self:toExponential(places - 1)
end
function methods.pow_base(self: any, value: any): any return D(value):pow(self) end
function methods.factorial(self: any): any
	local n = self:toNumber() + 1
	-- For enormous n, sinh(1/n) rounds to 1/n. Evaluate their product
	-- as 1 to avoid Studio flushing the reciprocal before multiplication.
	if n > 1e300 then
		return Decimal.pow(n / math.exp(1), n):mul(math.sqrt(2 * math.pi / n))
	end
	return Decimal.pow((n / math.exp(1)) * math.sqrt(n * math.sinh(1 / n) + 1 / (810 * n ^ 6)), n):mul(math.sqrt(2 * math.pi / n))
end
function methods.sinh(self: any): any return self:exp():sub(self:neg():exp()):div(2) end
function methods.cosh(self: any): any return self:exp():add(self:neg():exp()):div(2) end
function methods.tanh(self: any): any return self:sinh():div(self:cosh()) end
function methods.asinh(self: any): number return self:add(self:sqr():add(Decimal.ONE):sqrt()):ln() end
function methods.acosh(self: any): number return self:add(self:sqr():sub(Decimal.ONE):sqrt()):ln() end
function methods.atanh(self: any): number
	if self:abs():gte(1) then return NAN end
	return self:add(Decimal.ONE):div(Decimal.ONE:sub(self)):ln() / 2
end
function methods.ascensionPenalty(self: any, ascensions: number): any
	return if ascensions == 0 then self else self:pow(10 ^ -ascensions)
end
function methods.egg(self: any): any return self:add(9) end
function methods.isFinite(self: any): boolean return finite(self.mantissa) end
function methods.isNaN(self: any): boolean return self.mantissa ~= self.mantissa end
function methods.isPositiveInfinity(self: any): boolean return self.mantissa == math.huge end
function methods.isNegativeInfinity(self: any): boolean return self.mantissa == -math.huge end
function Decimal.affordGeometricSeries(resources: any, start: any, ratio: any, owned: any): any
	local r = D(ratio)
	local actualStart = D(start):mul(r:pow(owned))
	return Decimal.floor(D(resources):div(actualStart):mul(r:sub(1)):add(1):log10() / r:log10())
end
function Decimal.sumGeometricSeries(count: any, start: any, ratio: any, owned: any): any
	local r = D(ratio)
	return D(start):mul(r:pow(owned)):mul(Decimal.sub(1, r:pow(count))):div(Decimal.sub(1, r))
end
function Decimal.affordArithmeticSeries(resources: any, start: any, add: any, owned: any): any
	local a = D(add)
	local actualStart = D(start):add(D(owned):mul(a))
	local b = actualStart:sub(a:div(2))
	return b:neg():add(b:pow(2):add(a:mul(resources):mul(2)):sqrt()):div(a):floor()
end
function Decimal.sumArithmeticSeries(count: any, start: any, add: any, owned: any): any
	local n, a = D(count), D(add)
	local actualStart = D(start):add(D(owned):mul(a))
	return n:div(2):mul(actualStart:mul(2):add(n:sub(1):mul(a)))
end
function Decimal.efficiencyOfPurchase(cost: any, current: any, delta: any): any return D(cost):div(current):add(D(cost):div(delta)) end
function Decimal.randomDecimalForTesting(maxExponent: number): any
	if math.random() * 20 < 1 then return raw(0, 0) end
	local m = math.random() * 10
	if math.random() * 10 < 1 then m = round(m) end
	m *= sign(math.random() * 2 - 1)
	return ME(m, math.floor(math.random() * maxExponent * 2) - maxExponent)
end

local aliases: { [string]: string } = {
	negate = "neg", negated = "neg", sign = "sgn", plus = "add", subtract = "sub", minus = "sub",
	multiply = "mul", times = "mul", divide = "div", divideBy = "div", dividedBy = "div",
	reciprocal = "recip", reciprocate = "recip", compare = "cmp", equals = "eq", notEquals = "neq",
	compare_tolerance = "cmp_tolerance", equals_tolerance = "eq_tolerance", notEquals_tolerance = "neq_tolerance",
	logarithm = "log", decimalPlaces = "dp", valueOf = "toString", toJSON = "toString", toStringWithDecimalPlaces = "toExponential",
}
for alias, name in aliases do methods[alias] = methods[name] end
-- One wrapper provides Decimal.add(a, b) alongside a:add(b) for each method.
for name, method in methods do
	if Decimal[name] == nil then
		Decimal[name] = function(value: any, ...: any): any return method(D(value), ...) end
	end
end
-- Preserve upstream's static 10^integer fast path (including 10^0).
function Decimal.pow(value: any, other: any): any
	if value == 10 and type(other) == "number" and integer(other) then return raw(1, other) end
	return D(value):pow(other)
end
mt.__index = function(self: any, key: any): any
	if key == "m" then return self.mantissa elseif key == "e" then return self.exponent
	elseif key == "s" then return sign(self.mantissa) end
	return methods[key]
end
mt.__newindex = function(self: any, key: any, value: any)
	if key == "m" then rawset(self, "mantissa", value)
	elseif key == "e" then rawset(self, "exponent", value)
	elseif key == "s" then
		if value == 0 then self.e = 0; self.m = 0
		elseif self:sgn() ~= value then self.m = -self.m end
	else rawset(self, key, value) end
end
mt.__tostring = methods.toString
mt.__add = Decimal.add
mt.__sub = Decimal.sub
mt.__mul = Decimal.mul
mt.__div = Decimal.div
mt.__pow = Decimal.pow
mt.__unm = methods.neg
mt.__eq = methods.eq
mt.__lt = function(a: any, b: any): boolean return D(a):lessThan(b) end
mt.__le = function(a: any, b: any): boolean return D(a):lessThanOrEqualTo(b) end

Decimal.ZERO = Decimal.constant(0)
Decimal.ONE = Decimal.constant(1)
Decimal.MINUS_ONE = Decimal.constant(-1)
Decimal.MAX_VALUE = table.freeze(raw(1, EXP_LIMIT))
Decimal.MIN_VALUE = table.freeze(raw(1, -EXP_LIMIT))
Decimal.NUMBER_MAX_VALUE = Decimal.constant(1.7976931348623157e308)
Decimal.NUMBER_MIN_VALUE = table.freeze(raw(5, -324))
subnormalPool[1] = Decimal.NUMBER_MIN_VALUE
Decimal.NaN = table.freeze(raw(NAN, 0))
Decimal.POSITIVE_INFINITY = table.freeze(raw(math.huge, 0))
Decimal.NEGATIVE_INFINITY = table.freeze(raw(-math.huge, 0))
table.freeze(mt)
setmetatable(Decimal, { __call = function(_: any, value: any): any return Decimal.new(value) end })

return table.freeze(Decimal :: any) :: DecimalClass
