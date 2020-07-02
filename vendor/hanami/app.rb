# frozen_string_literal: true

require "hanami"
require "pathname"

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module Hanami
  def self.application?
    true
  end

  # Reopens Hanami::Configuration from `hanami`
  class Configuration
    class Model
      attr_accessor :databases
    end

    def model
      @model ||= Model.new
    end
  end

  module App
    module Routing
      class Resolver
        def initialize(container: Hanami.application.container, **)
          @container = container
        end

        def call(*, action)
          container["actions.#{action}"]
        end

        private

        attr_reader :container
      end
    end

    class Boot
      RUBY_FILE_EXT = ".rb"
      private_constant :RUBY_FILE_EXT

      @_booted = false

      def self.call(application: Hanami.application)
        return if @_booted

        configure_router(application.configuration)
        configure_action(application.configuration)
        configure_view(application)
        configure_model(application)

        load_components(application)

        @_booted = true
      end

      def self.configure_router(configuration)
        configuration.router.resolver = Hanami::App::Routing::Resolver
      end

      def self.configure_action(_configuration)
        require "hanami/controller"
      rescue LoadError
        # gem isn't present, let's move on with life
      end

      def self.configure_view(application)
        require "hanami/view"

        configuration = application.configuration
        Hanami::View.config.paths = [configuration.root.join("app", "templates").to_s]
        Hanami::View.config.layouts_dir = configuration.views.layouts_dir
        Hanami::View.config.layout = configuration.views.default_layout
        Hanami::View.class_eval do
          def self.inherited(subclass)
            super(subclass)

            subclass.config.template = template_name(subclass)
          end

          def self.template_name(view_class, inflector: Hanami.application.configuration.inflector)
            inflector.underscore(
              view_class.name.split("::Views::").last
            )
          end
        end

        application.container.register("view.context", Hanami::View::Context.new)
      rescue LoadError
        # gem isn't present, let's move on with life
      end

      def self.configure_model(application)
        require_relative "./model"

        application.configuration.model.databases.each do |name, (type, connection_url)|
          rom = ROM.container(type, connection_url) do |config|
            config.auto_registration(application.configuration.root.join("app"), namespace: application.namespace.name)
          end

          application.container.register("hanami.model.rom.container.#{name}", rom)
        end
      end

      def self.load_components(application)
        base_path = application.configuration.root.join("app")
        relative_path_from = base_path.to_s + File::SEPARATOR

        namespace = application.namespace
        inflector = application.configuration.inflector
        container = application.container

        load_components_for(base_path.join("views"), relative_path_from, namespace, inflector, container)
        load_directory(base_path.join("entities"))
        load_components_for(base_path.join("repositories"), relative_path_from, namespace, inflector, container)
        load_components_for(base_path.join("actions"), relative_path_from, namespace, inflector, container)
      end

      def self.load_directory(base_path)
        Dir.glob(base_path.join("**", "*#{RUBY_FILE_EXT}")).sort.each do |path|
          require_relative path
        end
      end

      def self.load_components_for(base_path, relative_path_from, namespace, inflector, container)
        Dir.glob(base_path.join("**", "*#{RUBY_FILE_EXT}")).sort.each do |path|
          require_relative path

          path = path.sub(relative_path_from, "").sub(RUBY_FILE_EXT, "")
          key = path.gsub(File::SEPARATOR, ".")

          begin
            component = namespace.const_get(inflector.classify(path))
          rescue NameError
            next
          end

          container.register(key, component.new)
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
