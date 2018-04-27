# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model::Configuration do
    class DummyModel
      include GraphqlRails::Model

      graphql do |c|
        c.attribute :id
        c.attribute :valid?
        c.attribute :level, type: :int
      end
    end

    class DummyMongoidModel
      include Mongoid::Document
      include GraphqlRails::Model

      field :name, type: String
      field :valid_at, type: Time
      field :test, type: Boolean

      graphql(&:include_model_attributes)
    end

    class DummyMongoidModelWithCustomFields
      include Mongoid::Document
      include GraphqlRails::Model

      field :name, type: String
      field :valid_at, type: Time
      field :test, type: Boolean
      field :secret, type: Boolean

      graphql do |c|
        c.include_model_attributes(except: :secret)
        c.attribute :surname
      end
    end

    class DummyActiveRecordModel < ActiveRecord::Base
      include GraphqlRails::Model
    end

    subject(:config) { model.graphql }

    let(:model) { DummyModel }

    describe '.graphql_type' do
      context 'when model is simple ruby class' do
        it 'returns type with correct fields' do
          expect(model.graphql.graphql_type.fields.keys).to match_array(%w[id isValid level])
        end
      end

      context 'when model is active record model' do
        let(:model) { DummyActiveRecordModel }

        let(:model_columns) do
          # rubocop:disable RSpec/VerifiedDoubles
          [
            double(name: 'id', cast_type: double(class: 'ActiveRecord::Type::Integer')),
            double(name: 'percents', cast_type: double(class: 'ActiveRecord::Type::Decimal')),
            double(
              name: 'name',
              cast_type: double(class: 'ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::MysqlString')
            )
          ]
          # rubocop:enable RSpec/VerifiedDoubles
        end

        before do
          allow(model).to receive(:columns).and_return(model_columns)

          model.graphql(&:include_model_attributes)
        end

        it 'includes all active record fields' do
          expect(config.graphql_type.fields.keys).to match_array(%w[id name percents])
        end
      end

      context 'when model is mongoid' do
        let(:model) { DummyMongoidModel }

        it 'includes all mongoid fields' do
          expect(model.graphql.graphql_type.fields.keys).to match_array(%w[id name validAt test])
        end

        context 'when model has custom graphql_rails attributes' do
          let(:model) { DummyMongoidModelWithCustomFields }

          it 'includes all mongoid and custom fields' do
            expect(config.graphql_type.fields.keys).to match_array(%w[id name validAt test surname])
          end
        end
      end

      it 'returns instance of graphql  type' do
        expect(config.graphql_type).to be_a(GraphQL::ObjectType)
      end
    end
  end
end
