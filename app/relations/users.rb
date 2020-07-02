# frozen_string_literal: true

module Cabin
  module Relations
    class Users < Hanami::Relation[:sql]
      schema(:users, infer: true)
    end
  end
end
