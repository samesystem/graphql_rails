require 'spec_helper'

module Graphiti
  RSpec.describe Controller::Configuration do
    class DummyModel
      include Model

      graphiti do |c|
        c.attribute :id
      end
    end

    class DummyController < Controller
      specify :some_method, accepts: :id, returns: DummyModel
      def some_method; end

      specify :some_other_method, accepts: [:id, :name], returns: DummyModel
      def some_other_method; end
    end

    subject(:configuration) { DummyController.controller_configuration }

    let(:controller) { DummyController }

    describe '#arguments_for' do
      it 'returns hash with graphql arguments as values' do
        expect(configuration.arguments_for(:some_method)).to eq('id' => kind_of(GraphQL::Argument))
      end
    end
  end
end
