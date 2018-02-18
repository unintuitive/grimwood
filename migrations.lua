local schema = require("lapis.db.schema")
local db = require("lapis.db")
local types = schema.types

return {
  [1] = function()
    schema.create_table("articles", {
      { "id", types.serial },
      { "title", types.text },
      { "content", types.text },
      { "date", types.date({ null = true})},

      "PRIMARY KEY (id)"
    })
    end,
  [2] = function()
    schema.create_table("users", {
      { "id", types.serial { unique = true, primary_key = true } },
      { "name", types.text },
      { "email", types.text { unique = true } },
      { "password", types.text },
      { "admin", types.boolean { default = false}}
    })

    schema.add_column("articles", "user_id", types.foreign_key)
    db.query("alter table articles add constraint user_fk foreign key (user_id) references users (id)")
  end,
  [3] = function()
    schema.add_column("articles", "slug", types.text({ null = true, unique = true }))
  end
}
