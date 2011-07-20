class Post < ActiveResource::Base
  self.site = "http://localhost:3000"
  self.format = :json
end
