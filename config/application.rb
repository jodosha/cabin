# frozen_string_literal: true

module Cabin
  class Application < Hanami::Application
    config.model.databases = {
      default: [:sql, "postgresql://localhost/cabin_development"]
    }
  end
end
