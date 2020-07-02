# frozen_string_literal: true

require "rom"
require "rom/sql"

module Hanami
  Entity = ROM::Struct
  Relation = ROM::Relation

  class Repository < ROM::Repository::Root
    module Fullstack
      def self.extended(repository)
        super

        namespace = Hanami.application.namespace
        repository.include(namespace::Deps[container: "hanami.model.rom.container.default"])
        repository.struct_namespace(namespace::Entities)
      end
    end

    def self.inherited(repository)
      super

      repository.extend(Fullstack) if Hanami.application?
      repository.commands :create,
                          use: :timestamps,
                          plugins_options: {
                            timestamps: {
                              timestamps: %i[created_at updated_at]
                            }
                          }
    end

    def all
      root.to_a
    end
  end

  module Model
    module SQL
      def self.migration(&blk)
        ROM::SQL.migration(&blk)
      end
    end
  end
end
