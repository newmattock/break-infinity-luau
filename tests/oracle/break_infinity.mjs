// MIT. Built from Patashu/break_infinity.js revision 22a00b9dcac4219760ba82e90c47ffba365958d6.
var A = Object.defineProperty;
var w = (s, t, r) => t in s ? A(s, t, { enumerable: !0, configurable: !0, writable: !0, value: r }) : s[t] = r;
var I = (s, t, r) => (w(s, typeof t != "symbol" ? t + "" : t, r), r);
const x = [];
for (let s = -324 + 1; s <= 308; s++)
  x.push(Number("1e" + s));
const y = 323;
function d(s) {
  return x[s + y];
}
function X(s) {
  let t = "";
  for (; t.length < s; )
    t += "0";
  return t;
}
const E = [];
function T(s) {
  if (s <= 0)
    return "";
  const t = E[s];
  if (t !== void 0)
    return t;
  const r = X(s);
  return E[s] = r, r;
}
function _(s) {
  return s > 0 ? "." + T(s) : "";
}
function P(s, t, r, i) {
  const n = t.mul(r.pow(i));
  return a.floor(
    s.div(n).mul(r.sub(1)).add(1).log10() / r.log10()
  );
}
function U(s, t, r, i) {
  return t.mul(r.pow(i)).mul(a.sub(1, r.pow(s))).div(a.sub(1, r));
}
function L(s, t, r, i) {
  const h = t.add(i.mul(r)).sub(r.div(2)), p = h.pow(2);
  return h.neg().add(p.add(r.mul(s).mul(2)).sqrt()).div(r).floor();
}
function O(s, t, r, i) {
  const n = t.add(i.mul(r));
  return s.div(2).mul(n.mul(2).plus(s.sub(1).mul(r)));
}
function G(s, t, r) {
  return s.div(t).add(s.div(r));
}
function l(s, t) {
  if (s.m === 0) {
    if (t.m === 0)
      return 0;
    if (t.m < 0)
      return 1;
    if (t.m > 0)
      return -1;
  }
  if (t.m === 0) {
    if (s.m < 0)
      return -1;
    if (s.m > 0)
      return 1;
  }
  if (s.m > 0)
    return t.m < 0 || s.e > t.e ? 1 : s.e < t.e ? -1 : s.m > t.m ? 1 : s.m < t.m ? -1 : 0;
  if (s.m < 0)
    return t.m > 0 || s.e > t.e ? -1 : s.e < t.e || s.m > t.m ? 1 : s.m < t.m ? -1 : 0;
  throw Error("Unreachable code");
}
const b = /* @__PURE__ */ new Map();
function M(s) {
  return b.get(s);
}
function c(s) {
  let t = b.get(s);
  return t === void 0 && (t = Object.freeze(new a(s)), b.set(s, t)), t;
}
function e(s) {
  if (s instanceof a)
    return s;
  if (typeof s == "number")
    return a.fromNumber(s);
  if (typeof s == "string")
    return a.fromString(s);
  if (s == null)
    return f;
  if (s.mantissa !== void 0 && s.exponent !== void 0)
    return o(s.mantissa, s.exponent);
  throw Error("Unsupported Decimal source type.");
}
function o(s, t) {
  const r = new a();
  return r.setMantissaExponent(s, t), r;
}
function u(s, t) {
  const r = new a();
  return r.setMantissaExponent_noNormalize(s, t), r;
}
class a {
  constructor(t) {
    /**
     * A number (double) with absolute value between [1, 10) OR exactly 0.
     * If mantissa is ever 10 or greater, it should be normalized
     * (divide by 10 and add 1 to exponent until it is less than 10,
     * or multiply by 10 and subtract 1 from exponent until it is 1 or greater).
     * Infinity/-Infinity/NaN will cause bad things to happen.
     */
    I(this, "mantissa", NaN);
    /**
     * A number (integer) between -EXP_LIMIT and EXP_LIMIT.
     * Non-integral/out of bounds will cause bad things to happen.
     */
    I(this, "exponent", NaN);
    if (t == null)
      this.m = 0, this.e = 0;
    else if (typeof t == "number")
      this.setFromNumber(t);
    else if (typeof t == "string")
      this.setFromString(t);
    else if (t instanceof a)
      this.copyFrom(t);
    else if (t.mantissa !== void 0 && t.exponent !== void 0)
      this.copyFrom(t);
    else
      throw Error("Unsupported Decimal source type.");
  }
  get m() {
    return this.mantissa;
  }
  set m(t) {
    this.mantissa = t;
  }
  get e() {
    return this.exponent;
  }
  set e(t) {
    this.exponent = t;
  }
  get s() {
    return this.sign();
  }
  set s(t) {
    if (t === 0) {
      this.e = 0, this.m = 0;
      return;
    }
    this.sgn() !== t && (this.m = -this.m);
  }
  //#region fromMantissaExponent
  setMantissaExponent(t, r) {
    if (!isFinite(t) || !isFinite(r)) {
      this.copyFrom(N);
      return;
    }
    this.m = t, this.e = r, this.normalize();
  }
  static fromMantissaExponent(t, r) {
    return o(t, r);
  }
  //#endregion
  //#region fromMantissaExponent_noNormalize
  /**
   * Well, you know what you're doing!
   */
  setMantissaExponent_noNormalize(t, r) {
    this.m = t, this.e = r;
  }
  static fromMantissaExponent_noNormalize(t, r) {
    return u(t, r);
  }
  //#endregion
  //#region fromDecimal
  copyFrom(t) {
    this.m = t.mantissa, this.e = t.exponent;
  }
  //#endregion
  //#region clone
  clone() {
    return u(this.m, this.e);
  }
  //#endregion
  //#region fromNumber
  setFromNumber_bypassCache(t) {
    if (!isFinite(t)) {
      this.setMantissaExponent_noNormalize(t, 0);
      return;
    }
    if (t === 0) {
      this.m = 0, this.e = 0;
      return;
    }
    this.e = Math.floor(Math.log10(Math.abs(t))), this.m = this.e === -324 ? t * 10 / 1e-323 : t / d(this.e), this.normalize();
  }
  setFromNumber(t) {
    const r = M(t);
    r === void 0 ? this.setFromNumber_bypassCache(t) : this.copyFrom(r);
  }
  static fromNumber_bypassCache(t) {
    const r = new a();
    return r.setFromNumber_bypassCache(t), r;
  }
  static fromNumber(t) {
    const r = M(t);
    return r === void 0 ? a.fromNumber_bypassCache(t) : r;
  }
  //#endregion
  //#region fromString
  setFromString_bypassCache(t) {
    if (t = t.toLowerCase(), t.indexOf("e") !== -1) {
      const r = t.split("e");
      this.m = parseFloat(r[0]), isNaN(this.m) && (this.m = 1), this.e = parseFloat(r[1]), this.normalize();
      return;
    }
    if (t === "nan") {
      this.copyFrom(N);
      return;
    }
    if (this.setFromNumber(parseFloat(t)), this.isNaN())
      throw Error("[DecimalError] Invalid argument: " + t);
  }
  setFromString(t) {
    const r = M(t);
    return r === void 0 ? this.setFromString_bypassCache(t) : this.copyFrom(r), this;
  }
  static fromString_bypassCache(t) {
    const r = new a();
    return r.setFromString_bypassCache(t), r;
  }
  static fromString(t) {
    const r = M(t);
    return r === void 0 ? a.fromString_bypassCache(t) : r;
  }
  //#endregion
  //#region fromValue
  static fromValue_noAlloc(t) {
    return e(t);
  }
  //#endregion
  //#region abs
  abs() {
    return u(Math.abs(this.m), this.e);
  }
  static abs(t) {
    return e(t).abs();
  }
  //#endregion
  //#region neg
  neg() {
    return u(-this.m, this.e);
  }
  static neg(t) {
    return e(t).neg();
  }
  negate() {
    return this.neg();
  }
  static negate(t) {
    return e(t).neg();
  }
  negated() {
    return this.neg();
  }
  static negated(t) {
    return e(t).neg();
  }
  //#endregion
  //#region sgn
  sgn() {
    return Math.sign(this.m);
  }
  static sgn(t) {
    return e(t).sgn();
  }
  sign() {
    return this.sgn();
  }
  static sign(t) {
    return e(t).sgn();
  }
  //#endregion
  //#region round
  round() {
    return this.e < -1 ? f : this.e < 17 ? a.fromNumber(Math.round(this.toNumber())) : this;
  }
  static round(t) {
    return e(t).round();
  }
  //#endregion
  //#region floor
  floor() {
    return this.isFinite() ? this.e < -1 ? Math.sign(this.m) >= 0 ? f : F : this.e < 17 ? a.fromNumber(Math.floor(this.toNumber())) : this : this;
  }
  static floor(t) {
    return e(t).floor();
  }
  //#endregion
  //#region ceil
  ceil() {
    return this.e < -1 ? Math.sign(this.m) > 0 ? m : f : this.e < 17 ? a.fromNumber(Math.ceil(this.toNumber())) : this;
  }
  static ceil(t) {
    return e(t).ceil();
  }
  //#endregion
  //#region trunc
  trunc() {
    return this.e < 0 ? f : this.e < 17 ? a.fromNumber(Math.trunc(this.toNumber())) : this;
  }
  static trunc(t) {
    return e(t).trunc();
  }
  //#endregion
  //#region add
  add(t) {
    if (!this.isFinite())
      return this;
    const r = e(t);
    if (!r.isFinite() || this.m === 0)
      return r;
    if (r.m === 0)
      return this;
    let i, n;
    if (this.e >= r.e ? (i = this, n = r) : (i = r, n = this), i.e - n.e > 17)
      return i;
    const h = Math.round(1e14 * i.m + 1e14 * n.m * d(n.e - i.e));
    return o(h, i.e - 14);
  }
  static add(t, r) {
    return e(t).add(r);
  }
  plus(t) {
    return this.add(t);
  }
  static plus(t, r) {
    return e(t).add(r);
  }
  //#endregion
  //#region sub
  sub(t) {
    return this.add(e(t).neg());
  }
  static sub(t, r) {
    return e(t).sub(r);
  }
  subtract(t) {
    return this.sub(t);
  }
  static subtract(t, r) {
    return e(t).sub(r);
  }
  static minus(t, r) {
    return e(t).sub(r);
  }
  minus(t) {
    return this.sub(t);
  }
  //#endregion
  //#region mul
  mul(t) {
    if (typeof t == "number")
      return t < 1e307 && t > -1e307 ? o(this.m * t, this.e) : o(this.m * 1e-307 * t, this.e + 307);
    const r = e(t);
    return o(this.m * r.m, this.e + r.e);
  }
  static mul(t, r) {
    return e(t).mul(r);
  }
  multiply(t) {
    return this.mul(t);
  }
  static multiply(t, r) {
    return e(t).mul(r);
  }
  times(t) {
    return this.mul(t);
  }
  static times(t, r) {
    return e(t).mul(r);
  }
  //#endregion
  //#region div
  div(t) {
    return this.mul(e(t).recip());
  }
  static div(t, r) {
    return e(t).div(r);
  }
  divide(t) {
    return this.div(t);
  }
  static divide(t, r) {
    return e(t).div(r);
  }
  divideBy(t) {
    return this.div(t);
  }
  dividedBy(t) {
    return this.div(t);
  }
  //#endregion
  //#region recip
  recip() {
    return o(1 / this.m, -this.e);
  }
  static recip(t) {
    return e(t).recip();
  }
  reciprocal() {
    return this.recip();
  }
  static reciprocal(t) {
    return e(t).recip();
  }
  reciprocate() {
    return this.recip();
  }
  static reciprocate(t) {
    return e(t).reciprocate();
  }
  //#endregion
  //#region cmp
  /**
   * -1 for less than value, 0 for equals value, 1 for greater than value
   */
  cmp(t) {
    const r = e(t);
    return this.isNaN() ? r.isNaN() ? 0 : -1 : r.isNaN() ? 1 : l(this, r);
  }
  static cmp(t, r) {
    return e(t).cmp(r);
  }
  compare(t) {
    return this.cmp(t);
  }
  static compare(t, r) {
    return e(t).cmp(r);
  }
  //#endregion
  //#region eq
  eq(t) {
    const r = e(t);
    return this.e === r.e && this.m === r.m;
  }
  static eq(t, r) {
    return e(t).eq(r);
  }
  equals(t) {
    return this.eq(t);
  }
  static equals(t, r) {
    return e(t).eq(r);
  }
  //#endregion
  //#region neq
  neq(t) {
    return !this.eq(t);
  }
  static neq(t, r) {
    return e(t).neq(r);
  }
  notEquals(t) {
    return this.neq(t);
  }
  static notEquals(t, r) {
    return e(t).notEquals(r);
  }
  //#endregion
  //#region lt
  lt(t) {
    const r = e(t);
    return this.m === 0 ? r.m > 0 : r.m === 0 ? this.m <= 0 : this.e === r.e ? this.m < r.m : this.m > 0 ? r.m > 0 && this.e < r.e : r.m > 0 || this.e > r.e;
  }
  static lt(t, r) {
    return e(t).lt(r);
  }
  lessThan(t) {
    if (this.isNaN())
      return !1;
    const r = e(t);
    return r.isNaN() ? !1 : l(this, r) < 0;
  }
  //#endregion
  //#region lte
  lte(t) {
    return !this.gt(t);
  }
  static lte(t, r) {
    return e(t).lte(r);
  }
  lessThanOrEqualTo(t) {
    if (this.isNaN())
      return !1;
    const r = e(t);
    return r.isNaN() ? !1 : l(this, r) < 1;
  }
  //#endregion
  //#region gt
  gt(t) {
    const r = e(t);
    return this.m === 0 ? r.m < 0 : r.m === 0 ? this.m > 0 : this.e === r.e ? this.m > r.m : this.m > 0 ? r.m < 0 || this.e > r.e : r.m < 0 && this.e < r.e;
  }
  static gt(t, r) {
    return e(t).gt(r);
  }
  greaterThan(t) {
    if (this.isNaN())
      return !1;
    const r = e(t);
    return r.isNaN() ? !1 : l(this, r) > 0;
  }
  //#endregion
  //#region gte
  gte(t) {
    return !this.lt(t);
  }
  static gte(t, r) {
    return e(t).gte(r);
  }
  greaterThanOrEqualTo(t) {
    if (this.isNaN())
      return !1;
    const r = e(t);
    return r.isNaN() ? !1 : l(this, r) > -1;
  }
  //#endregion
  //#region max
  max(t) {
    const r = e(t);
    return this.lt(r) ? r : this;
  }
  static max(t, r) {
    return e(t).max(r);
  }
  //#endregion
  //#region min
  min(t) {
    const r = e(t);
    return this.gt(r) ? r : this;
  }
  static min(t, r) {
    return e(t).min(r);
  }
  //#endregion
  //#region clamp
  clamp(t, r) {
    return this.max(t).min(r);
  }
  static clamp(t, r, i) {
    return e(t).clamp(r, i);
  }
  //#endregion
  //#region clampMin
  clampMin(t) {
    return this.max(t);
  }
  static clampMin(t, r) {
    return e(t).clampMin(r);
  }
  //#endregion
  //#region clampMax
  clampMax(t) {
    return this.min(t);
  }
  static clampMax(t, r) {
    return e(t).clampMax(r);
  }
  //#endregion
  //#region cmp_tolerance
  cmp_tolerance(t, r) {
    const i = e(t);
    return this.eq_tolerance(i, r) ? 0 : this.cmp(i);
  }
  static cmp_tolerance(t, r, i) {
    return e(t).cmp_tolerance(r, i);
  }
  compare_tolerance(t, r) {
    return this.cmp_tolerance(t, r);
  }
  static compare_tolerance(t, r, i) {
    return e(t).cmp_tolerance(r, i);
  }
  //#endregion
  //#region eq_tolerance
  /**
   * Tolerance is a relative tolerance, multiplied by the greater of the magnitudes of the two arguments.
   * For example, if you put in 1e-9, then any number closer to the
   * larger number than (larger number)*1e-9 will be considered equal.
   */
  eq_tolerance(t, r) {
    const i = e(t);
    return a.lte(
      this.sub(i).abs(),
      a.max(this.abs(), i.abs()).mul(r)
    );
  }
  static eq_tolerance(t, r, i) {
    return e(t).eq_tolerance(r, i);
  }
  equals_tolerance(t, r) {
    return this.eq_tolerance(t, r);
  }
  static equals_tolerance(t, r, i) {
    return e(t).eq_tolerance(r, i);
  }
  //#endregion
  //#region neq_tolerance
  neq_tolerance(t, r) {
    return !this.eq_tolerance(t, r);
  }
  static neq_tolerance(t, r, i) {
    return e(t).neq_tolerance(r, i);
  }
  notEquals_tolerance(t, r) {
    return this.neq_tolerance(t, r);
  }
  static notEquals_tolerance(t, r, i) {
    return e(t).notEquals_tolerance(r, i);
  }
  //#endregion
  //#region lt_tolerance
  lt_tolerance(t, r) {
    const i = e(t);
    return !this.eq_tolerance(i, r) && this.lt(i);
  }
  static lt_tolerance(t, r, i) {
    return e(t).lt_tolerance(r, i);
  }
  //#endregion
  //#region lte_tolerance
  lte_tolerance(t, r) {
    const i = e(t);
    return this.eq_tolerance(i, r) || this.lt(i);
  }
  static lte_tolerance(t, r, i) {
    return e(t).lte_tolerance(r, i);
  }
  //#endregion
  //#region gt_tolerance
  gt_tolerance(t, r) {
    const i = e(t);
    return !this.eq_tolerance(i, r) && this.gt(i);
  }
  static gt_tolerance(t, r, i) {
    return e(t).gt_tolerance(r, i);
  }
  //#endregion
  //#region gte_tolerance
  gte_tolerance(t, r) {
    const i = e(t);
    return this.eq_tolerance(i, r) || this.gt(i);
  }
  static gte_tolerance(t, r, i) {
    return e(t).gte_tolerance(r, i);
  }
  //#endregion
  //#region log10
  log10() {
    return this.e + Math.log10(this.m);
  }
  static log10(t) {
    return e(t).log10();
  }
  //#endregion
  //#region absLog10
  absLog10() {
    return this.e + Math.log10(Math.abs(this.m));
  }
  static absLog10(t) {
    return e(t).absLog10();
  }
  //#endregion
  //#region pLog10
  pLog10() {
    return this.m <= 0 || this.e < 0 ? 0 : this.log10();
  }
  static pLog10(t) {
    return e(t).pLog10();
  }
  //#endregion
  //#region log
  log(t) {
    return Math.LN10 / Math.log(t) * this.log10();
  }
  static log(t, r) {
    return e(t).log(r);
  }
  logarithm(t) {
    return this.log(t);
  }
  static logarithm(t, r) {
    return e(t).log(r);
  }
  //#endregion
  //#region log2
  log2() {
    return 3.321928094887362 * this.log10();
  }
  static log2(t) {
    return e(t).log2();
  }
  //#endregion
  //#region ln
  ln() {
    return 2.302585092994045 * this.log10();
  }
  static ln(t) {
    return e(t).ln();
  }
  //#endregion
  //#region pow10
  static pow10(t) {
    return Number.isInteger(t) ? u(1, t) : o(Math.pow(10, t % 1), Math.trunc(t));
  }
  //#endregion
  //#region pow
  pow(t) {
    if (this.m === 0)
      return this;
    const r = t instanceof a ? t.toNumber() : t, i = this.e * r;
    let n;
    if (Number.isSafeInteger(i) && (n = Math.pow(this.m, r), isFinite(n) && n !== 0))
      return o(n, i);
    const h = Math.trunc(i), p = i - h;
    if (n = Math.pow(10, r * Math.log10(this.m) + p), isFinite(n) && n !== 0)
      return o(n, h);
    const g = a.pow10(r * this.absLog10());
    return this.sign() === -1 ? Math.abs(r % 2) === 1 ? g.neg() : Math.abs(r % 2) === 0 ? g : N : g;
  }
  static pow(t, r) {
    return typeof t == "number" && t === 10 && typeof r == "number" && Number.isInteger(r) ? u(1, r) : e(t).pow(r);
  }
  //#endregion
  //#region exp
  exp() {
    const t = this.toNumber();
    return -706 < t && t < 709 ? a.fromNumber(Math.exp(t)) : a.pow(Math.E, t);
  }
  static exp(t) {
    return e(t).exp();
  }
  //#endregion
  //#region sqr
  sqr() {
    return o(Math.pow(this.m, 2), this.e * 2);
  }
  static sqr(t) {
    return e(t).sqr();
  }
  //#endregion
  //#region sqrt
  sqrt() {
    return this.m < 0 ? N : this.e % 2 !== 0 ? o(Math.sqrt(this.m) * 3.16227766016838, Math.floor(this.e / 2)) : o(Math.sqrt(this.m), Math.floor(this.e / 2));
  }
  static sqrt(t) {
    return e(t).sqrt();
  }
  //#endregion
  //#region cube
  cube() {
    return o(Math.pow(this.m, 3), this.e * 3);
  }
  static cube(t) {
    return e(t).cube();
  }
  //#endregion
  //#region cbrt
  cbrt() {
    let t = 1, r = this.m;
    r < 0 && (t = -1, r = -r);
    const i = t * Math.pow(r, 1 / 3), n = this.e % 3;
    return n === 1 || n === -2 ? o(i * 2.154434690031883, Math.floor(this.e / 3)) : n !== 0 ? o(i * 4.641588833612778, Math.floor(this.e / 3)) : o(i, Math.floor(this.e / 3));
  }
  static cbrt(t) {
    return e(t).cbrt();
  }
  //#endregion
  //#region cbrt
  dp() {
    if (!this.isFinite())
      return NaN;
    if (this.exponent >= 17)
      return 0;
    const t = this.mantissa;
    let r = -this.exponent, i = 1;
    for (; Math.abs(Math.round(t * i) / i - t) > 1e-10; )
      i *= 10, r++;
    return r > 0 ? r : 0;
  }
  static dp(t) {
    return e(t).dp();
  }
  decimalPlaces() {
    return this.dp();
  }
  static decimalPlaces(t) {
    return e(t).dp();
  }
  //#endregion
  /**
   * If you're willing to spend 'resourcesAvailable' and want to buy something
   * with exponentially increasing cost each purchase (start at priceStart,
   * multiply by priceRatio, already own currentOwned), how much of it can you buy?
   * Adapted from Trimps source code.
   */
  static affordGeometricSeries(t, r, i, n) {
    return P(
      e(t),
      e(r),
      e(i),
      n
    );
  }
  /**
   * How much resource would it cost to buy (numItems) items if you already have currentOwned,
   * the initial price is priceStart and it multiplies by priceRatio each purchase?
   */
  static sumGeometricSeries(t, r, i, n) {
    return U(
      t,
      e(r),
      e(i),
      n
    );
  }
  /**
   * If you're willing to spend 'resourcesAvailable' and want to buy something with additively
   * increasing cost each purchase (start at priceStart, add by priceAdd, already own currentOwned),
   * how much of it can you buy?
   */
  static affordArithmeticSeries(t, r, i, n) {
    return L(
      e(t),
      e(r),
      e(i),
      e(n)
    );
  }
  /**
   * How much resource would it cost to buy (numItems) items if you already have currentOwned,
   * the initial price is priceStart and it adds priceAdd each purchase?
   * Adapted from http://www.mathwords.com/a/arithmetic_series.htm
   */
  static sumArithmeticSeries(t, r, i, n) {
    return O(
      e(t),
      e(r),
      e(i),
      e(n)
    );
  }
  /**
   * When comparing two purchases that cost (resource) and increase your resource/sec by (deltaRpS),
   * the lowest efficiency score is the better one to purchase.
   * From Frozen Cookies:
   * http://cookieclicker.wikia.com/wiki/Frozen_Cookies_(JavaScript_Add-on)#Efficiency.3F_What.27s_that.3F
   */
  static efficiencyOfPurchase(t, r, i) {
    return G(
      e(t),
      e(r),
      e(i)
    );
  }
  static randomDecimalForTesting(t) {
    if (Math.random() * 20 < 1)
      return u(0, 0);
    let r = Math.random() * 10;
    Math.random() * 10 < 1 && (r = Math.round(r)), r *= Math.sign(Math.random() * 2 - 1);
    const i = Math.floor(Math.random() * t * 2) - t;
    return o(r, i);
  }
  /**
   * When mantissa is very denormalized, use this to normalize much faster.
   */
  normalize() {
    if (this.m >= 1 && this.m < 10)
      return this;
    if (this.m === 0)
      return this.m = 0, this.e = 0, this;
    const t = Math.floor(Math.log10(Math.abs(this.m)));
    return this.m = t === -324 ? this.m * 10 / 1e-323 : this.m / d(t), this.e += t, this;
  }
  toNumber() {
    if (!this.isFinite())
      return this.mantissa;
    if (this.e > 308)
      return this.m > 0 ? Number.POSITIVE_INFINITY : Number.NEGATIVE_INFINITY;
    if (this.e < -324)
      return 0;
    if (this.e === -324)
      return this.m > 0 ? 5e-324 : -5e-324;
    const t = this.m * d(this.e);
    if (!isFinite(t) || this.e < 0)
      return t;
    const r = Math.round(t);
    return Math.abs(r - t) < 1e-10 ? r : t;
  }
  mantissaWithDecimalPlaces(t) {
    if (!this.isFinite())
      return this.mantissa;
    if (this.m === 0)
      return 0;
    const r = t + 1, i = Math.ceil(Math.log10(Math.abs(this.m))), n = Math.round(this.m * Math.pow(10, r - i)) * Math.pow(10, i - r);
    return parseFloat(n.toFixed(Math.max(r - i, 0)));
  }
  toString() {
    return this.isFinite() ? this.e <= -9e15 || this.m === 0 ? "0" : this.e < 21 && this.e > -7 ? this.toNumber().toString() : this.m + "e" + (this.e >= 0 ? "+" : "") + this.e : this.mantissa.toString();
  }
  toExponential(t) {
    if (!this.isFinite())
      return this.mantissa.toString();
    if (this.e <= -9e15 || this.m === 0)
      return "0" + _(t) + "e+0";
    if (this.e > -324 && this.e < 308)
      return this.toNumber().toExponential(t);
    isFinite(t) || (t = 17);
    const r = t + 1, i = Math.max(1, Math.ceil(Math.log10(Math.abs(this.m))));
    return (Math.round(this.m * Math.pow(10, r - i)) * Math.pow(10, i - r)).toFixed(Math.max(r - i, 0)) + "e" + (this.e >= 0 ? "+" : "") + this.e;
  }
  toFixed(t) {
    if (!this.isFinite())
      return this.mantissa.toString();
    if (this.e <= -9e15 || this.m === 0)
      return "0" + _(t);
    if (this.e >= 17) {
      const r = this.m.toString().replace(".", ""), i = T(this.e - r.length + 1);
      return r + i + _(t);
    }
    return this.toNumber().toFixed(t);
  }
  toPrecision(t) {
    return this.e <= -7 ? this.toExponential(t - 1) : t > this.e ? this.toFixed(t - this.e - 1) : this.toExponential(t - 1);
  }
  valueOf() {
    return this.toString();
  }
  toJSON() {
    return this.toString();
  }
  toStringWithDecimalPlaces(t) {
    return this.toExponential(t);
  }
  pow_base(t) {
    return e(t).pow(this);
  }
  factorial() {
    const t = this.toNumber() + 1;
    return a.pow(
      t / Math.E * Math.sqrt(t * Math.sinh(1 / t) + 1 / (810 * Math.pow(t, 6))),
      t
    ).mul(Math.sqrt(2 * Math.PI / t));
  }
  // Some hyperbolic trig functions that happen to be easy
  sinh() {
    return this.exp().sub(this.negate().exp()).div(2);
  }
  cosh() {
    return this.exp().add(this.negate().exp()).div(2);
  }
  tanh() {
    return this.sinh().div(this.cosh());
  }
  asinh() {
    return a.ln(this.add(this.sqr().add(m).sqrt()));
  }
  acosh() {
    return a.ln(this.add(this.sqr().sub(m).sqrt()));
  }
  atanh() {
    return this.abs().gte(1) ? Number.NaN : a.ln(this.add(m).div(m.sub(this))) / 2;
  }
  /**
   * Joke function from Realm Grinder
   */
  ascensionPenalty(t) {
    return t === 0 ? this : this.pow(Math.pow(10, -t));
  }
  /**
   * Joke function from Cookie Clicker. It's 'egg'
   */
  egg() {
    return this.add(9);
  }
  isFinite() {
    return isFinite(this.mantissa);
  }
  isNaN() {
    return this.mantissa !== this.mantissa;
  }
  isPositiveInfinity() {
    return this.mantissa === S.mantissa;
  }
  isNegativeInfinity() {
    return this.mantissa === q.mantissa;
  }
  static const(t) {
    return c(t);
  }
  static constant(t) {
    return c(t);
  }
  static get ZERO() {
    return f;
  }
  static get ONE() {
    return m;
  }
  static get MINUS_ONE() {
    return F;
  }
  static get MAX_VALUE() {
    return C;
  }
  static get MIN_VALUE() {
    return R;
  }
  static get NUMBER_MAX_VALUE() {
    return V;
  }
  static get NUMBER_MIN_VALUE() {
    return B;
  }
  static get NaN() {
    return N;
  }
  static get POSITIVE_INFINITY() {
    return S;
  }
  static get NEGATIVE_INFINITY() {
    return q;
  }
}
const C = u(1, 9e15), R = u(1, -9e15), f = c(0), m = c(1), F = c(-1), V = c(Number.MAX_VALUE), B = c(Number.MIN_VALUE), N = u(Number.NaN, 0), S = u(Number.POSITIVE_INFINITY, 0), q = u(Number.NEGATIVE_INFINITY, 0);
export {
  a as default
};
