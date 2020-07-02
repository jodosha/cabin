# frozen_string_literal: true

module Cabin
  module Views
    module Home
      class Index < Hanami::View
        expose(:users)
      end
    end
  end
end
