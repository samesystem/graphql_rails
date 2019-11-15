# frozen_string_literal: true

require 'graphql_rails'

module GraphqlRails
  # provides all helpers neccesary for testing graphql controllers. It is similar to rspec controller specs
  #
  # Adds 3 helper methods in to rspec test:
  # * mutation
  # * query
  # * result
  # `mutation` and `query`` methods are identical
  #
  # Usage:
  # it 'works' do
  #   mutation(:createUser, params: { name: 'John'}, context: { current_user_id: 1 })
  #   expect(response).to be_successful?
  #   expect(response)not_to be_failure?
  #   expect(response.result).to be_a(User)
  #   expect(response.errors).to be_empty
  # end
  module RSpecControllerHelpers
    # contains all details about testing response. Similar as in rspec controllers tests
    class Response
      def initialize(request)
        @request = request
      end

      def result
        request.object_to_return
      end

      def errors
        request.errors
      end

      def success?
        request.errors.empty?
      end

      def successful?
        success?
      end

      def failure?
        !success?
      end

      private

      attr_reader :request
    end

    # instance which has similar behavior as
    class FakeContext
      extend Forwardable

      attr_reader :schema

      def_delegators :@provided_values, :[], :[]=, :to_h, :key?, :fetch

      def initialize(values:, schema:)
        @errors = []
        @provided_values = values
        @schema = schema
      end

      def add_error(error)
        @errors << error
      end
    end

    class SingleControllerSchemaBuilder
      attr_reader :controller

      def initialize(controller)
        @controller = controller
      end

      def call
        config = controller.controller_configuration
        action_by_name = config.action_by_name
        controller_path = controller.name.underscore.sub(/_controller\Z/, '')

        router = Router.draw do
          action_by_name.keys.each do |action_name|
            query("#{action_name}_test", to: "#{controller_path}##{action_name}", group: :graphql_rspec_helpers)
          end
        end

        router.graphql_schema(:graphql_rspec_helpers)
      end
    end

    # controller request object more suitable for testing
    class Request < GraphqlRails::Controller::Request
      def initialize(params, context)
        super(nil, params, context)
      end
    end

    def query(query_name, params: {}, context: {})
      schema_builder = SingleControllerSchemaBuilder.new(described_class)
      context_object = FakeContext.new(values: context, schema: schema_builder.call)
      request = Request.new(params, context_object)
      described_class.new(request).call(query_name)

      @response = Response.new(request)
      @response
    end

    def mutation(*args)
      query(*args)
    end

    def response
      @response
    end
  end
end
