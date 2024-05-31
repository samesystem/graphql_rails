# frozen_string_literal: true

require 'spec_helper'
require 'graphql_rails/rspec_controller_helpers'

module GraphqlRails
  RSpec.describe RSpecControllerHelpers do
    class TestableController < GraphqlRails::Controller
      Stats = Struct.new(:json) do
        include GraphqlRails::Model

        graphql do |c|
          c.attribute :json, type: :string!
        end
      end

      action(:paginated_index).paginated.returns("[#{Stats}!]!")
      action(:boom).returns('bool!')
      action(:index).returns(Stats)

      def paginated_index
        []
      end

      def index
        Stats.new(
          {
            received_params: params,
            received_context: graphql_request.context.to_h
          }.to_json
        )
      end

      def boom
        raise 'Boom!'
      end
    end

    RSpecLikeRunner = Struct.new(:described_class) do
      include RSpecControllerHelpers
    end

    subject(:runner) { RSpecLikeRunner.new(TestableController) }

    let(:action_params) { { id: 1 } }
    let(:action_context) { { current_user_id: 1 } }

    describe '#query' do
      subject(:json_result) do
        runner.query(action_name, params: action_params, context: action_context)
        JSON.parse(runner.response.result.json).deep_symbolize_keys
      end

      let(:action_name) { :index }

      it 'triggers controller with correct params' do
        expect(json_result).to eq(
          received_params: action_params.to_h,
          received_context: action_context.to_h
        )
      end

      context 'when testing paginated action' do
        let(:action_name) { :paginated_index }

        it 'triggers controller with correct params' do
          runner.query(:paginated_index, context: action_context)

          expect(runner.response.result).to eq([])
        end
      end
    end

    describe '#mutation' do
      subject(:json_result) do
        runner.mutation(:index, params: action_params, context: action_context)
        JSON.parse(runner.response.result.json).deep_symbolize_keys
      end

      it 'triggers controller with correct params' do
        expect(json_result).to eq(
          received_params: action_params.to_h,
          received_context: action_context.to_h
        )
      end
    end

    describe '#response' do
      it 'includes controller name' do
        runner.query(:index, params: action_params, context: action_context)
        expect(runner.response.controller).to eq TestableController
      end

      it 'includes action name' do
        runner.query(:index, params: action_params, context: action_context)
        expect(runner.response.action_name).to eq :index
      end

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
