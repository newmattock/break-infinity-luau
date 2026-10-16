# break-infinity-luau

A standalone, typed Luau port of [Patashu/break_infinity.js](https://github.com/Patashu/break_infinity.js). Drop `Decimal.luau` into a Roblox ModuleScript or require it from the Luau CLI. It has no runtime dependencies.

Values use `mantissa * 10^exponent`, allowing magnitudes up to roughly `10^(9e15)`. Like upstream, it uses double precision and prioritizes speed over arbitrary precision. Use strings for values that exceed the native number range.

## Usage

Roblox: create a ModuleScript named **Decimal**, paste the contents of `Decimal.luau` into it, and put it in ReplicatedStorage.

```luau
local Decimal = require(game:GetService("ReplicatedStorage"):WaitForChild("Decimal"))

local coins = Decimal.new("1e1000")
local earned = Decimal.new("2e1000")
print(coins:add(earned):toString()) -- 3e+1000
print(Decimal.mul("1e400", 5))      -- 5e+400
print((coins + earned):toFixed(0))  -- expands the number into digits

local affordable = Decimal.affordGeometricSeries("1e1000", 10, 1.15, 0)
print(affordable)
```

Luau CLI:

```luau
local Decimal = require("./Decimal")
local value: Decimal.Decimal = Decimal.new("6e900")
print(value:div(2)) -- 3e+900
```

`Decimal(value)` is also supported. Arithmetic methods use `value:add(other)`; static helpers use `Decimal.add(value, other)`. Supported sources are numbers, strings, Decimal values, and `{ mantissa = number, exponent = number }` tables.

## API

The port covers the public methods and aliases in both npm **2.1.1** and repository revision [`22a00b9dcac4219760ba82e90c47ffba365958d6`](https://github.com/Patashu/break_infinity.js/tree/22a00b9dcac4219760ba82e90c47ffba365958d6). The repository still labels itself 2.1.1 but has renamed constructor mutators since the published package. Both sets are available here.

| Area | Methods |
| --- | --- |
| Construction | `new`, `fromNumber`, `fromString`, `fromDecimal`, `fromValue`, `fromValue_noAlloc`, `fromMantissaExponent`, `fromMantissaExponent_noNormalize`, cache-bypass variants, `clone` |
| Mutation | `setFromNumber`, `setFromString`, their cache-bypass variants, `setMantissaExponent`, `setMantissaExponent_noNormalize`, `copyFrom`, `normalize`; legacy fluent `from*` instance methods |
| Arithmetic | `abs`, `neg`, `sgn`, `round`, `floor`, `ceil`, `trunc`, `add`, `sub`, `mul`, `div`, `recip`, and upstream aliases |
| Comparison | `cmp`, `eq`, `neq`, `lt`, `lte`, `gt`, `gte`, long aliases, tolerance variants, `min`, `max`, `clamp`, `clampMin`, `clampMax` |
| Powers and logs | `log10`, `absLog10`, `pLog10`, `log`, `logarithm`, `log2`, `ln`, static `pow10`, `pow`, `pow_base`, `exp`, `sqr`, `sqrt`, `cube`, `cbrt`, `factorial` |
| Hyperbolic | `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh` |
| Conversion | `toNumber`, `toString`, `toExponential`, `toFixed`, `toPrecision`, `toStringWithDecimalPlaces`, `mantissaWithDecimalPlaces`, `dp`, `decimalPlaces`, `valueOf`, `toJSON` |
| Purchase helpers | `affordGeometricSeries`, `sumGeometricSeries`, `affordArithmeticSeries`, `sumArithmeticSeries`, `efficiencyOfPurchase` |
| Other | `isFinite`, `isNaN`, `isPositiveInfinity`, `isNegativeInfinity`, `const`, `constant`, `randomDecimalForTesting`, `ascensionPenalty`, `egg` |

Constants: `ZERO`, `ONE`, `MINUS_ONE`, `MAX_VALUE`, `MIN_VALUE`, `NUMBER_MAX_VALUE`, `NUMBER_MIN_VALUE`, `NaN`, `POSITIVE_INFINITY`, `NEGATIVE_INFINITY`.

Fields `m`, `e`, and `s` alias mantissa, exponent, and sign. Assigning `s = 0` also resets the exponent. Exported types are `Decimal`, `DecimalSource`, `MantissaExponent`, and `DecimalClass`.

Operators `+`, `-`, `*`, `/`, `^`, unary `-`, `==`, `<`, `<=`, `>`, and `>=` are supported. Arithmetic accepts a Decimal with a number or string operand; use two Decimal objects for comparison operators. Methods such as `:eq(5)` accept ordinary values. Luau always considers a table equal to itself, so use `:eq()` when checking NaN equality. `tostring(value)` invokes `:toString()`.

## Compatibility details

- Arithmetic follows upstream, including its quirks: `Decimal.new(0):pow(0)` returns zero; `:recip()` on zero produces NaN; short and long comparison aliases can differ for NaN. Infinite *numeric* inputs are supported, but upstream lowercases strings before parsing, so `"Infinity"` is rejected. The large-negative `toFixed` sign/length quirk is also preserved.
- This is approximate binary64 arithmetic. Platform math functions can differ in their last few bits, occasionally placing a near-power-of-ten result in an equivalent adjacent mantissa/exponent representation. Bit-for-bit agreement for all mathematical functions is not promised.
- Formatting reproduces JS notation thresholds and uses exact binary64 expansion for fixed-digit rounding. Some upstream custom formatting branches accept precision values outside native JS's 0–100 limit; those branches are retained.
- To prevent impractical allocations, each custom zero expansion is limited to **1,000,000 zeroes**. Infinite precision requests fail instead of entering upstream's unbounded zero-building loop. Use `toExponential` for extreme magnitudes.
- All constants, cached values, the module table, and the shared instance metatable are frozen. Clone a constant before using mutators. Arithmetic may reuse an input or cached constant, as upstream does; clone a result if you need to mutate it.
- `:toJSON()` returns a string. Roblox `HttpService:JSONEncode` does not automatically call this method; explicitly encode the returned string and rebuild it with `Decimal.new` when loading.

## Roblox Studio verification

Open `Decimal-Studio-Test.rbxlx` in Studio and press **F5**. The place is local and includes the module, reference fixtures, server Script, and client LocalScript. No publication, HTTP access, or live DataStore access is needed. Results are printed to Output with the `[DECIMAL_STUDIO]` prefix.

The Studio test found and fixed native underflow differences in powers, factorial, and subnormal double handling. **180,274 checks passed per environment**, with zero failures. Roblox JSON round trips and client/server transport of `1e1000` also passed.

Roblox may turn subnormal native literals such as `5e-324` into zero before a function call. Use `Decimal.new("5e-324")` for these values. Raw buffer doubles are preserved by the port, and `toNumber()` retains their bits; later native Roblox arithmetic can still flush them. Tests transport these oracle values as raw IEEE-754 bytes rather than allowing Studio's source parser to erase them.

## Tests

Pre-generated fixtures are included, so the Luau tests need no Node packages or network access:

```sh
luau tests/unit.luau
luau tests/run.luau
luau tests/run-published.luau
luau-analyze Decimal.luau tests/unit.luau tests/check-reference.luau
```

To regenerate fixtures, install the pinned development dependency and run:

```sh
npm ci --ignore-scripts
npm run fixtures
npm run fixtures:published
```

The repository oracle is a vendored JavaScript build of the pinned commit, covered by the root MIT license. The published-package oracle comes from npm 2.1.1. Fixtures include fundamental values, huge exponents, subnormal doubles, all aliases, formatting boundaries, purchase helpers, and deterministic random inputs. `reference-summary.json` files record case counts and seeds.

Numeric comparisons use a relative tolerance of `2e-11`; Decimal exponents must match exactly except when equivalent representations differ by one exponent. Strings, booleans, and API presence are checked exactly; error cases must throw. Infinite-precision inputs that hang upstream and fixed-string expansions too large to allocate are excluded from oracle generation and tested as bounded errors in Luau.

Verification on October 15, 2026: **89,927 repository checks**, **89,839 published-package checks**, and **508 Luau unit checks** passed. Strict type analysis passed. Tested with Luau revision `8387cfb461b38ce09e37c1e4c2811538ef1bf5cb` on Apple Silicon macOS. Roblox Studio 0.743.0.7431133 also passed both complete suites on the server and client, plus Roblox JSON/module-loading checks, a network round trip, and a separate 20-result raw-double audit. See `studio-verification.json` and `studio-test-results.log`.

The upstream repository's own Number-compatibility suite reports 418 failures out of 9,820 tests on this host. Those tests compare the approximate library against native JavaScript Number semantics; this port's differential suites compare against the actual library behavior.

## License

MIT. The upstream copyright notice is retained in `LICENSE`.
