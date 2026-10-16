// Run with Node 22+ and break_infinity.js 2.1.1 installed (npm ci).
const published = process.env.ORACLE === 'published';
const {default: Decimal} = await import(published ? 'break_infinity.js' : './oracle/break_infinity.mjs');
import {writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
const out = fileURLToPath(new URL(published ? './published-reference.luau' : './reference.luau', import.meta.url));
const cases = [];
const counts = {};
function lua(x) {
  if (x === undefined || x === null) return 'nil';
  if (typeof x === 'number' && x !== 0 && Math.abs(x) < 2.2250738585072014e-308) {
    const bytes = Buffer.alloc(8); bytes.writeDoubleLE(x);
    return 'buffer.readf64(buffer.fromstring("'+[...bytes].map(b=>'\\'+String(b).padStart(3,'0')).join('')+'"),0)';
  }
  if (typeof x === 'number') return Number.isNaN(x) ? '(0/0)' : x === Infinity ? 'math.huge' : x === -Infinity ? '-math.huge' : Object.is(x,-0) ? '-0' : String(x);
  if (typeof x === 'string') return JSON.stringify(x);
  if (typeof x === 'boolean') return String(x);
  if (Array.isArray(x)) return '{'+x.map(lua).join(',')+'}';
  return '{'+Object.entries(x).map(([k,v]) => `[${lua(k)}]=${lua(v)}`).join(',')+'}';
}
function add(mode, method, args) {
  let result, kind;
  try {
    result = mode === 'instance' ? new Decimal(args[0])[method](...args.slice(1)) : Decimal[method](...args);
    if (result instanceof Decimal) {kind='decimal'; result={m:result.m,e:result.e};}
    else kind=typeof result;
  } catch {kind='error'; result='';}
  cases.push([mode,method,args,kind,result]);
  counts[method]=(counts[method]??0)+1;
}
const fundamental=[0,1,-1,1.1,-1.1,.9,-.9,Infinity,-Infinity,NaN];
const general=[345,-745,123456789,-987654321,4,-5,3.7e63,-7.3e36,7.23e222,-2.23e201,5.323e-47,-8.252e-21,1.98e-241,-6.79e-215];
const extreme=['1e900','-6e900','1e-900','-6e-900','1e9000000000000000','1e-9000000000000000',Number.MIN_VALUE,-Number.MIN_VALUE,Number.MAX_VALUE,-Number.MAX_VALUE,'9.999999999999999e1000','1e-324','9e-324'];
const values=[...fundamental,...general,...extreme];
const unary=['abs','neg','negate','negated','sgn','sign','round','floor','ceil','trunc','recip','reciprocal','reciprocate','log10','absLog10','pLog10','log2','ln','exp','sqr','sqrt','cube','cbrt','dp','decimalPlaces','toNumber','toString','valueOf','toJSON','factorial','sinh','cosh','tanh','asinh','acosh','atanh','egg','isFinite','isNaN','isPositiveInfinity','isNegativeInfinity','clone'];
for(const x of values) for(const method of unary) {
  if(typeof Decimal.prototype[method]!=='function') continue;
  add('instance',method,[x]);
  if(Object.hasOwn(Decimal,method) && typeof Decimal[method]==='function') add('static',method,[x]);
}
const binary=['add','plus','sub','subtract','minus','mul','multiply','times','div','divide','recip','cmp','compare','eq','equals','neq','notEquals','lt','lte','gt','gte','lessThan','lessThanOrEqualTo','greaterThan','greaterThanOrEqualTo','max','min','clampMin','clampMax'];
for(const x of values) for(const y of values) for(const method of binary) {
  add('instance',method,[x,y]);
  if(Object.hasOwn(Decimal,method) && typeof Decimal[method]==='function') add('static',method,[x,y]);
}
for(const x of values) {
  for(const y of [-10,-3,-2,-1,-.5,0,.1,.5,1,2,3,10,1000,Infinity,NaN]) {
    add('instance','pow',[x,y]); add('static','pow',[x,y]);
    add('instance','pow_base',[x,y]);
  }
  for(const base of [0,1,2,Math.E,10,-2,Infinity,NaN]) for(const method of ['log','logarithm']) {
    add('instance',method,[x,base]);add('static',method,[x,base]);
  }
  for(const p of [undefined,0,1,2,5,17,25,100,-1,101,NaN,Infinity]) for(const method of ['toFixed','toExponential','toPrecision','toStringWithDecimalPlaces','mantissaWithDecimalPlaces']) {
    // Expanding 1e9e15 into a string would exhaust memory in JS.
    if (method==='toFixed' && new Decimal(x).e > 10000) continue;
    // Upstream loops forever building zeroes for some Infinity precision inputs.
    if (p===Infinity) continue;
    add('instance',method,[x,p]);
  }
  for(const a of [0,1,2,10]) add('instance','ascensionPenalty',[x,a]);
  add('instance','clamp',[x,-100,100]); add('static','clamp',[x,-100,100]);
}
for(const x of [1,-1,0,'1e900','1e-900',NaN,Infinity]) for(const y of [1,1.000000001,-1,0,'1e900','1.000000001e900',NaN,Infinity]) {
  for(const t of [0,1e-8,.1]) for(const method of ['cmp_tolerance','compare_tolerance','eq_tolerance','equals_tolerance','neq_tolerance','notEquals_tolerance','lt_tolerance','lte_tolerance','gt_tolerance','gte_tolerance']) {
    add('instance',method,[x,y,t]);add('static',method,[x,y,t]);
  }
}
for(const x of [...values,'','foo','e1000','1e','1ee2','1.23foo','  2.5  ','+Infinity','-Infinity','0x10','.5','2.e3',{mantissa:60,exponent:8}]) {
  for(const method of ['fromValue_noAlloc','fromString','fromString_bypassCache','fromNumber','fromNumber_bypassCache']) {
    if(method.includes('String') && typeof x!=='string') continue;
    if(method.includes('Number') && typeof x!=='number') continue;
    if (published && typeof x==='object') continue;
    if (Object.hasOwn(Decimal,method)) add('static',method,[x]);
  }
}
for(const m of [0,1,-1,60,-.00001,1e308,5e-324,NaN,Infinity]) for(const e of [-900,0,8,900,NaN,Infinity]) {
  add('static','fromMantissaExponent',[m,e]);add('static','fromMantissaExponent_noNormalize',[m,e]);
}
for(const x of [-900.5,-324,0,.5,308,900,9e15,NaN,Infinity]) add('static','pow10',[x]);
for(const owned of [0,1,10]) for(const start of [1,10,'1e900']) for(const ratio of [1,1.01,2,10]) {
  add('static','affordGeometricSeries',['1e1000',start,ratio,owned]);
  add('static','sumGeometricSeries',[100,start,ratio,owned]);
  add('static','affordArithmeticSeries',['1e1000',start,ratio,owned]);
  add('static','sumArithmeticSeries',[100,start,ratio,owned]);
  add('static','efficiencyOfPurchase',[start,ratio,owned]);
}
let seed=0x12345678;
function rand(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/2**32;}
for(let i=0;i<250;i++) {
  const a={mantissa:(rand()*18-9),exponent:Math.floor(rand()*4000-2000)};
  const b={mantissa:(rand()*18-9),exponent:i%2 ? a.exponent+Math.floor(rand()*40-20) : Math.floor(rand()*4000-2000)};
  const av=published ? `${a.mantissa}e${a.exponent}` : a;
  const bv=published ? `${b.mantissa}e${b.exponent}` : b;
  for(const method of ['add','sub','mul','div','cmp','eq','lt','lte','gt','gte']) add('static',method,[av,bv]);
  add('instance','pow',[av,rand()*20-10]);add('instance','sqrt',[av]);add('instance','cbrt',[av]);
}
// Formatting boundaries and halfway cases exercise exact binary64 conversion.
for (const x of [1.005,1.015,2.55,2.675,1.25,-1.25,-1.5,-2.5,9.999,99.995,1e-7,1e-6,1e20,1e21]) {
  for (const p of [0,1,2,3,17,30,100]) {
    for (const method of ['toString','toFixed','toExponential','toPrecision']) add('instance',method,[x,p]);
  }
}
for (let i=0;i<200;i++) {
  const x=(rand()*2-1)*10**Math.floor(rand()*600-300);
  for (const method of ['toString','toFixed','toExponential','toPrecision']) add('instance',method,[x,5]);
}
const prototypes=Object.getOwnPropertyNames(Decimal.prototype).filter(n=>n!=='constructor'&&typeof Object.getOwnPropertyDescriptor(Decimal.prototype,n).value==='function');
const statics=Object.getOwnPropertyNames(Decimal).filter(n=>!['length','name','prototype'].includes(n)&&typeof Object.getOwnPropertyDescriptor(Decimal,n).value==='function');
writeFileSync(out,'--!nocheck\n-- Generated by generate-reference.mjs against break_infinity.js 2.1.1.\nlocal cases: any = '+lua(cases)+'\nreturn cases\n');
writeFileSync(fileURLToPath(new URL(published ? './published-api-surface.luau' : './api-surface.luau',import.meta.url)),'return '+lua({instance:prototypes,static:statics})+'\n');
writeFileSync(fileURLToPath(new URL(published ? './published-reference-summary.json' : './reference-summary.json',import.meta.url)),JSON.stringify({upstream:'break_infinity.js',version:'2.1.1',revision:published ? 'npm:2.1.1' : '22a00b9dcac4219760ba82e90c47ffba365958d6',cases:cases.length,seed:'0x12345678',counts},null,2)+'\n');
console.log(`Generated ${cases.length} ${published ? 'npm 2.1.1' : 'repository 22a00b9'} reference cases.`);
