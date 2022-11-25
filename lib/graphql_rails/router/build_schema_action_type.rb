# frozen_string_literal: true

module GraphqlRails
  class Router
    # Builds GraphQL type used in graphql schema
    class BuildSchemaActionType
      ROUTES_KEY = :__routes__

      # @private
      class SchemaActionType < GraphQL::Schema::Object
        def self.inspect
          "#{GraphQL::Schema::Object}(#{graphql_name})"
        end

        class << self
          def fields_for_nested_routes(type_name_prefix:, scoped_routes:)
            routes_by_scope = scoped_routes.dup
            unscoped_routes = routes_by_scope.delete(ROUTES_KEY) || []

            scoped_only_fields(type_name_prefix, routes_by_scope)
            unscoped_routes.each { route_field(_1) }
          end

          private

          def route_field(route)
            field(*route.name, **route.field_options)
          end

          def scoped_only_fields(type_name_prefix, routes_by_scope)
            routes_by_scope.each_pair do |scope_name, inner_scope_routes|
              scope_field(scope_name, "#{type_name_prefix}#{scope_name.to_s.camelize}", inner_scope_routes)
            end
          end

          def scope_field(scope_name, scope_type_name, scoped_routes)
            scope_type = build_scope_type_class(
              type_name: scope_type_name,
              scoped_routes: scoped_routes
            )

            field(scope_name.to_s.camelize(:lower), scope_type, null: false)
            define_method(scope_type_name.underscore) { self }
          end

          def build_scope_type_class(type_name:, scoped_routes:)
            Class.new(SchemaActionType) do
              graphql_name("#{type_name}Scope")

              fields_for_nested_routes(
                type_name_prefix: type_name,
                scoped_routes: scoped_routes
              )
            end
          end
        end
      end

      def self.call(**kwargs)
        new(**kwargs).call
      end

      def initialize(type_name:, routes:)
        @type_name = type_name
        @routes = routes
      end

      def call
        type_name = self.type_name
        scoped_routes = self.scoped_routes

        Class.new(SchemaActionType) do
          graphql_name(type_name)

          fields_for_nested_routes(
            type_name_prefix: type_name,
            scoped_routes: scoped_routes
          )
        end
      end

      private

      attr_reader :type_name, :routes

      def scoped_routes
        routes.each_with_object({}) do |route, result|
          scope_names = route.scope_names.map { _1.to_s.camelize(:lower) }
          path_to_routes = scope_names + [ROUTES_KEY]
          deep_append(result, path_to_routes, route)
        end
      end

      # adds array element to nested hash
      # usage:
      #   deep_hash =   { a: { b: [1] } }
      #   deep_append(deep_hash, [:a, :b], 2)
      #   deep_hash #=> { a: { b: [1, 2] } }
      def deep_append(hash, keys, value)
        deepest_hash = hash
        *other_keys, last_key = keys

        other_keys.each do |key|
          deepest_hash[key] ||= {}
          deepest_hash = deepest_hash[key]
        end
        deepest_hash[last_key] ||= []
        deepest_hash[last_key] += [value]
      end
    end
  end
end
