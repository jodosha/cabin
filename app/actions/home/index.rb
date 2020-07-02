# frozen_string_literal: true

require "hanami/action"

module Cabin
  module Actions
    module Home
      class Index < Hanami::Action
        include Deps[view: "views.home.index", users: "repositories.user"]

        def handle(*, res)
          res[:users] = users.all
          res.render(view)
        end
      end
    end
  end
end
