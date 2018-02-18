local Model = require ("lapis.db.model").Model

local Articles = Model:extend("articles", {
  relations = {
    { "user", belongs_to = "Users"}
  }
})

function Articles:all()
  return Articles:select("ORDER BY date desc LIMIT 10")
end

return Articles
