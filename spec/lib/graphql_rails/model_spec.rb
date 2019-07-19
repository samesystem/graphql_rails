# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model do
    subject(:model) { plain_model }

    let(:plain_model) do
      Class.new do
        include GraphqlRails::Model

        graphql do |c|
          c.attribute :is_plain, type: :bool!
        end

        def self.name
          'DummyModel'
        end
      end
    end

    describe '.graphql' do
      it 'returns model configuration' do
        expect(model.graphql).to be_a(Model::Configuration)
      end

      context 'when inheritance is used' do
        subject(:model) do
          Class.new(plain_model) do
            graphql do |c|
              c.attribute :is_child, type: :bool!
            end
          end
        end

        it 'does not modify parent class config' do
          parent_fields = plain_model.graphql.graphql_type.all_fields.map(&:name)
          expect(parent_fields).to match_array(%w[isPlain])
        end

        it 'inherits parent class graphql configuration' do
          child_fields = model.graphql.graphql_type.all_fields.map(&:name)
          expect(child_fields).to match_array(%w[isPlain isChild])
        end
      end
    end
  end
end
