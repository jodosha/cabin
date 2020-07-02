# frozen_string_literal: true

require "hanami"
require "pathname"

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module Hanami
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

        configure_action(application.configuration)
        configure_view(application.configuration)
        configure_router_resolver(application.configuration)
        load_components(application)

        @_booted = true
      end

      def self.configure_action(_configuration)
        require "hanami/controller"
      rescue LoadError
        # gem isn't present, let's move on with life
      end

      def self.configure_view(configuration)
        require "hanami/view"

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
      rescue LoadError
        # gem isn't present, let's move on with life
      end

      def self.configure_router_resolver(configuration)
        configuration.router.resolver = Hanami::App::Routing::Resolver
      end

      def self.load_components(application)
        base_path = application.configuration.root.join("app")
        relative_path_from = base_path.to_s + File::SEPARATOR

        namespace = application.namespace
        inflector = application.configuration.inflector
        container = application.container

        # FIXME: `reverse` is a ugly hack to force views to be loaded before actions,
        #        because actions depends on views and so they must be loaded first.
        Dir.glob(base_path.join("**", "*#{RUBY_FILE_EXT}")).sort.reverse.each do |path|
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
