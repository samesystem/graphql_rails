# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe QueryRunner do
    class DummyQueryRunnerController < GraphqlRails::Controller
      action(:do_something).permit(:val).returns(:string)

      def do_something
        params[:val] || 'OK'
      end
    end

    subject(:query_runner) { described_class.new(params: params, router: router) }

    let(:params) do
      {
        query: query,
        variables: variables
      }
    end

    let(:query) { 'query { doSomething }' }
    let(:variables) { {} }

    let(:router) do
      Router.draw do
        query :do_something, to: 'graphql_rails/dummy_query_runner#do_something'
      end
    end

    describe '#call' do
      subject(:call) { query_runner.call }

      context 'when variables are not used' do
        it 'returns correct json' do
          result = call.to_h['data']['doSomething']
          expect(result).to eq 'OK'
        end
      end

      context 'when variables are used' do
        let(:query) { 'query($val: String!) { doSomething(val: $val) }' }
        let(:variables) { { val: 'success!' } }

        context 'when variables are given as Hash' do
          it 'returns correct json' do
            result = call.to_h['data']['doSomething']
            expect(result).to eq 'success!'
          end
        end

        context 'when variables are given as JSON string' do
          let(:variables) { { val: 'success!' }.to_json }

          it 'returns correct json' do
            result = call.to_h['data']['doSomething']
            expect(result).to eq 'success!'
          end
        end

        context 'when variables are given as unsupported type' do
          let(:variables) { :unsupported }

          it 'returns correct json' do
            expect { call }.to raise_error('Unexpected parameter: :unsupported')
          end
        end
      end
    end
  end
end
