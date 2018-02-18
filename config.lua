local config = require("lapis.config")

config("development", {
  postgres = {
    host = "127.0.0.1",
    user = postgres,
    password = 'password1!',
    database = 'grimwood_db'
  }
})

config("production", {
  port = 80,
  num_workers = 2,
  code_cache = "on",
  session_name = "my_session",
  secret = "grimwood-secret-key",
  postgres = {
    host = "127.0.0.1",
    user = postgres,
    password = 'password1!',
    database = 'grimwood_db'
  }
})
