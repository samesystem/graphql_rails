# frozen_string_literal: true

require 'spec_helper'
require 'graphql_rails/rspec_controller_helpers'

module GraphqlRails
  RSpec.describe RSpecControllerHelpers do
    class TestableClass < GraphqlRails::Controller
      def index
        {
          received_params: params,
          received_context: graphql_request.context.to_h
        }
      end

      def boom
        raise 'Boom!'
      end
    end

    RSpecLikeRunner = Struct.new(:described_class) do
      include RSpecControllerHelpers
    end

    subject(:runner) { RSpecLikeRunner.new(TestableClass) }

    let(:action_params) { { 'id' => 1 } }
    let(:action_context) { { current_user_id: 1 } }

    describe '#query' do
      before do
        allow(GraphqlRails::RSpecControllerHelpers::FakeSchema).to receive(:new).and_call_original
      end

      it 'triggers controller with correct params' do
        runner.query(:index, params: action_params, context: action_context)

        expect(runner.response.result).to eq(
          received_params: action_params.to_h,
          received_context: action_context.to_h
        )
      end

      it 'FakeSchema returns cursor' do
        runner.query(:index, params: action_params, context: action_context)

        expect(RSpecControllerHelpers::FakeSchema.new.cursor_encoder).to eq(GraphQL::Schema::Base64Encoder)
      end
    end

    describe '#mutation' do
      it 'triggers controller with correct params' do
        runner.mutation(:index, params: action_params, context: action_context)

        expect(runner.response.result).to eq(
          received_params: action_params.to_h,
          received_context: action_context.to_h
        )
      end
    end

    describe '#response' do
      context 'when request was successful' do
        it 'sets status to success' do
          runner.query(:index, params: action_params, context: action_context)
          expect(runner.response)
            .to be_success
            .and be_successful
        end
      end

      context 'when error happens' do
        it 'registers error' do
          runner.query(:boom)
          expect(runner.response.errors.map(&:message)).to eq ['Boom!']
        end

        it 'sets status to failure' do
          runner.query(:boom)
          expect(runner.response).to be_failure
        end
      end
    end
  end
end
