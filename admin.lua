local csrf = require("lapis.csrf")
local respond_to = require("lapis.application").respond_to
local app_helpers = require("lapis.application")

local yield_error, capture_errors,
assert_error = app_helpers.yield_error, app_helpers.capture_errors, app_helpers.assert_error

-- Models
local Articles = require("models.Articles")
local Users = require("models.Users")

-- Utility function
function to_slug(str)
  return string.lower(string.gsub(string.gsub(str,"[^ A-Za-z]",""),"[ ]+","-"))
end

return function(app)

  -- Admin routes
  -- TODO: Named route
  app:get("/admin", capture_errors(function(self)
  -- TODO: DRY
    if not self.session.current_user then
      yield_error("Not authorized.")
    end
    self.articles = assert_error(Articles:all())
    if not self.articles then
      yield_error("No articles found.")
    else
      return { render = "admin.index" }
    end
  end))

  -- TODO: Named route
  app:match("/admin/:login", respond_to({
    GET = capture_errors(function(self)
      self.csrf_token = csrf.generate_token(self)
      return { render = "admin.login" }
    end),
    POST = capture_errors(function(self)
      csrf.assert_token(self)
      if self.params.login then
        local user = assert_error(Users:verify(self.params))
        if not user then
          -- TODO: Refactor this. It's pulling the error from the model...
          yield_error("Could not verify user.")
        else
          self.session.current_user = { id = user.id, name = user.name, email = user.email }
          return { redirect_to = "/admin" }
        end
      else
        return { redirect_to = "/admin/login" }
      end
    end)
  }))

  app:get("admin_logout", "/admin/logout", function(self)
    self.session.current_user = nil
    return { redirect_to = "/" }
  end)

  -- TODO: Named route
  app:match("/admin/article/:id", respond_to({
    GET = capture_errors(function(self)
      -- TODO: DRY
      if not self.session.current_user then
        yield_error("Not authorized.")
      end
      if self.params.id then
        if self.params.id == "create" then
          self.article = {
            id = "create",
            title = "",
            date = os.date('%Y-%m-%d'),
            content = ""
          }
          return { render = "admin.article" }
        else
          local article = assert_error(Articles:find(self.params.id))
          if not article then
            yield_error("Article not found.")
          else
            self.article = article
            return { render = "admin.article" }
          end
        end
      end
    end),
    POST = capture_errors(function(self)
      -- TODO: DRY
      if not self.session.current_user then
        yield_error("Not authorized.")
      end
      if self.params.id then
        if self.params.id == "create" then
          local slug = to_slug(self.params.title)
          article = Articles:create({
            title = self.params.title,
            date = self.params.date,
            content = self.params.content,
            slug = slug,
            user_id = self.session.current_user.id
          })
          return { redirect_to = "/admin" }
        else
          local article = assert_error(Articles:find(self.params.id))
          if article then
            article:update({
              title = self.params.title,
              date = self.params.date,
              content = self.params.content,
            })
          end
          return { redirect_to = "/admin" }
        end
      else
        return { redirect_to = "/admin" }
      end
    end)
  }))

  app:match("article_delete", "/admin/article/:id/:action", function(self)
    -- TODO: DRY
    if not self.session.current_user then
      yield_error("Not authorized.")
    end
    if self.params.action and self.params.id then
      if self.params.action == "delete" then
        local article = assert_error(Articles:find(self.params.id))
        if article then
          article:delete()
        end
        return { redirect_to = "/admin" }
      end
    end
  end)

end
