# frozen_string_literal: true

require "hanami/action"

module Cabin
  module Actions
    module Home
      class Index < Hanami::Action
        include Deps[view: "views.home.index"]

        def handle(*, res)
          res.render(view)
        end
      end
    end
  end
end
