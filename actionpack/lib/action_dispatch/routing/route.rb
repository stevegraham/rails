module ActionDispatch
  module Routing # :nodoc:
    class Route # :nodoc:
      extend ActiveSupport::Autoload

      DEFAULT_REGEXP = /[^\.\/\?]+/.freeze

      autoload :Formatter
      autoload :OptimizedPath

      attr_reader :app, :path, :defaults, :name

      attr_reader :constraints
      alias :conditions :constraints

      attr_accessor :precedence

      ##
      # +path+ is a path constraint.
      # +constraints+ is a hash of constraints to be applied to this route.
      def initialize(name, app, path, constraints, defaults = {})
        @name        = name
        @app         = app
        @path        = path

        # Unwrap any constraints so we can see what's inside for route generation.
        # This allows the formatter to skip over any mounted applications or redirects
        # that shouldn't be matched when using a url_for without a route name.
        while app.is_a?(Routing::Mapper::Constraints) do
          app = app.app
        end
        @dispatcher  = app.is_a?(Routing::RouteSet::Dispatcher)

        @constraints = constraints
        @defaults    = defaults
        @required_defaults = nil
        @required_parts    = nil
        @parts             = nil
        @precedence        = 0
      end

      def requirements # :nodoc:
        # needed for rails `rake routes`
        path.requirements.merge(@defaults).delete_if { |_,v| /.+?/ == v }
      end

      def regular?
        if path.anchored
          regexps = requirements.values.grep(Regexp)
          regexps.all? { |v| DEFAULT_REGEXP == v }
        end
      end

      def segments
        path.names
      end

      def required_keys
        required_parts + required_defaults.keys
      end

      def score(constraints)
        required_keys = path.required_names
        supplied_keys = constraints.map { |k,v| v && k.to_s }.compact

        return -1 unless (required_keys - supplied_keys).empty?

        score = (supplied_keys & path.names).length
        score + (required_defaults.length * 2)
      end

      def parts
        @parts ||= segments.map(&:to_sym)
      end
      alias :segment_keys :parts

      def format(path_options)
        path_options.delete_if do |key, value|
          value.to_s == defaults[key].to_s && !required_parts.include?(key)
        end

        Formatter.format(path, path_options)
      end

      def optimized_path
        OptimizedPath.build(path)
      end

      def optional_parts
        @optional_parts ||= path.optional_names.map(&:to_sym)
      end

      def required_parts
        @required_parts ||= path.required_names.map(&:to_sym)
      end

      def required_default?(key)
        (constraints[:required_defaults] || []).include?(key)
      end

      def required_defaults
        @required_defaults ||= @defaults.dup.delete_if do |k,_|
          parts.include?(k) || !required_default?(k)
        end
      end

      def dispatcher?
        @dispatcher
      end

      def matches?(request)
        constraints.all? do |method, value|
          next true unless request.respond_to?(method)

          case value
          when Regexp, String
            value === request.send(method).to_s
          when Array
            value.include?(request.send(method))
          when TrueClass
            request.send(method).present?
          when FalseClass
            request.send(method).blank?
          else
            value === request.send(method)
          end
        end
      end

      def ip
        constraints[:ip] || //
      end

      def verb
        constraints[:request_method] || //
      end
    end
  end
end
