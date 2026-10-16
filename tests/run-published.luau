--!strict
local check = require("./check-reference")
check(require("./published-reference"), require("./published-api-surface"))
