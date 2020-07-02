# frozen_string_literal: true

require_relative "./app"
require_relative "../../config/application"
require "hanami/init"

Hanami::App::Boot.call
