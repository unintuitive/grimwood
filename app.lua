local lapis = require("lapis")
local app_helpers = require("lapis.application")
local config = require("lapis.config")

-- Models
local Articles = require("models.Articles")

-- Base application configuration
local app = lapis.Application()
local yield_error, capture_errors, assert_error = app_helpers.yield_error, app_helpers.capture_errors, app_helpers.assert_error
app:enable("etlua")
app.layout = require "views.layout"
config("production", {
  measure_performance = true
})

-- Load admin routes
local admin = require("admin")
admin(app)

-- Public article routes
app:match("index", "/", capture_errors(function(self)
  self.articles = assert_error(Articles:all())
  if not self.articles then
    yield_error("No articles found.")
  else
    return { render = "index"}
  end
end))

app:get("/article/:slug", capture_errors(function(self)
  local article = Articles:find({ slug = self.params.slug })
  if not article then
    yield_error("Article not found.")
  else
    self.article = article
    return { render = "article" }
  end
end))

return app
