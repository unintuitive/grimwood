local Model = require ("lapis.db.model").Model
local bcrypt = require "bcrypt"

local Users = Model:extend("users", {
  relations = {
    { "articles", has_many = "Articles" }
  }
})

function Users:get_user(username)
  local username = string.lower(username)
  return unpack(self:select("where lower(email)=? limit 1", username))
end

function Users:verify(params)
  local user = self:get_user(params.email)

  -- No user found with that username
  if not user then
    return false, "Invalid username or password."
  end

  -- Verify password and remove password from memory
  local verified = bcrypt.verify(params.password, user.password)
  user.password = nil
  params = nil

  if verified then
    return user
  else
    return false, "Invalid username or password."
  end
end

return Users
