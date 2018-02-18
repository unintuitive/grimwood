local db = require("lapis.db")
local bcrypt = require "bcrypt"

local log_rounds = 2

local digest = bcrypt.digest("password", log_rounds)
assert(bcrypt.verify("password", digest))

-- TODO: Insert statement to create user

-- db.update("users", {
--   password = digest },
-- {
--   id = 1
-- })
