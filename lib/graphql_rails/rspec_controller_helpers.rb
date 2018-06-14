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

      def_delegators :@provided_values, :[], :[]=, :to_h, :key?, :fetch

      def initialize(values:)
        @errors = []
        @provided_values = values
      end

      def add_error(error)
        @errors << error
      end

      def schema
        FakeSchema.new
      end
    end

    # instance which has similar behavior as
    class FakeSchema
      def initialize; end

      def cursor_encoder
        GraphQL::Schema::Base64Encoder
      end
    end

    # controller request object more suitable for testing
    class Request < GraphqlRails::Controller::Request
      def initialize(params, context)
        super(nil, params, context)
      end
    end

    def query(query_name, params: {}, context: {})
      context_object = FakeContext.new(values: context)
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
