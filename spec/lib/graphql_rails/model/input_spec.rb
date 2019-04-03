# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe Input do
      class DummyModel
        include GraphqlRails::Model

        graphql do |c|
          c.description 'Used for test purposes'
          c.attribute :id
          c.attribute :valid?
          c.attribute :level, type: :int, description: 'over 9000!'
        end
      end

      subject(:input) { described_class.new(DummyModel, input_name) }

      let(:input_name) { :search_criteria }
      let(:model) { DummyModel }

      describe '#graphql_input_type' do
        subject(:graphql_input_type) { input.graphql_input_type }

        before do
          input.attribute(:first_name, type: :string!)
          input.attribute(:last_name, type: :string!)
        end

        context 'with attributes' do
          it 'returns graphql input with arguments' do
            expect(graphql_input_type.arguments.keys).to match_array(%w[firstName lastName])
          end
        end
      end
    end
  end
end
