# frozen_string_literal: true

require_relative "./vendor/hanami/app" # FIXME: this is a temporary workaround
require_relative "config/application"

require "rom-sql"
require "rom/sql/rake_task"

task :environment do
  require "hanami/init" # FIXME: this is a temporary workaround
end

namespace :db do
  task setup: :environment do
    require_relative "./vendor/hanami/model"
    type, database_url = Hanami.application.configuration.model.databases.first.last

    ROM::SQL::RakeSupport.env = ROM.container(type, database_url) do |config|
      config.gateways[:default].use_logger(Logger.new($stdout))
    end
  end
end
