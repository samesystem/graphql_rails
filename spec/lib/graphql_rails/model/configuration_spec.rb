# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model::Configuration do
    class DummyModelConfigTestItem
      include Model

      graphql.attribute :name

      def name
        'item'
      end
    end

    subject(:config) { model.graphql }

    let(:model) do
      Class.new do
        include GraphqlRails::Model

        graphql do |c|
          c.description 'Used for test purposes'
          c.attribute :id
          c.attribute :valid?
          c.attribute :level, type: :int, description: 'over 9000!'
        end

        def self.name
          'DummyModel'
        end
      end
    end

    describe '#attribute' do
      let(:model) do
        Class.new do
          include GraphqlRails::Model

          graphql do |c|
            c.description 'Used for test purposes'
            c.attribute :paginated_list, type: "[#{DummyModelConfigTestItem}!]!", paginated: true
            c.attribute :field_with_args, permit: { name: :string! }
            c.attribute(:paginated_list_with_args, type: "[#{DummyModelConfigTestItem}!]!")
             .permit(name: :string!)
             .paginated
          end

          def self.name
            'DummyModel'
          end

          def paginated_list
            ['a'] * 1000
          end

          def field_with_args(name:)
            "hello #{name}!"
          end

          def paginated_list_with_args(name:)
            ["hello #{name}!"] * 10
          end
        end
      end

      context 'when attribute is paginated' do
        let(:field) { model.graphql.graphql_type.fields['paginatedList'] }

        it 'returns connection type' do
          expect(field.type.to_type_signature).to eq 'DummyModelConfigTestItemConnection!'
        end

        it 'contains connection arguments' do
          expect(field.arguments.keys).to match_array(%w[after before first last])
        end
      end

      context 'when attribute accepts arguments' do
        let(:field) { model.graphql.graphql_type.fields['fieldWithArgs'] }

        it 'returns correct type' do
          expect(field.type.to_type_signature).to eq 'String'
        end

        it 'contains correct arguments' do
          expect(field.arguments.keys).to match_array(%w[name])
        end
      end

      context 'when attribute is paginated and accepts arguments' do
        let(:field) { model.graphql.graphql_type.fields['paginatedListWithArgs'] }

        it 'returns connection type' do
          expect(field.type.to_type_signature).to eq 'DummyModelConfigTestItemConnection!'
        end

        it 'contains connection and specified arguments' do
          expect(field.arguments.keys).to match_array(%w[after before first last name])
        end
      end

      context 'when attribute definition contains required flag' do
        let(:model) do
          Class.new do
            include GraphqlRails::Model

            graphql do |c|
              c.description 'Used for test purposes'
              c.attribute :required_field, required: true
            end

            def self.name
              'DummyModel'
            end
          end
        end

        let(:field) { model.graphql.graphql_type.fields['requiredField'] }

        it 'is registered as required' do
          expect(field.type).to be_a_kind_of(GraphQL::NonNullType)
        end
      end
    end

    describe '#graphql_type' do
      subject(:graphql_type) { config.graphql_type }

      context 'when model is simple ruby class' do
        it 'returns type with correct fields' do
          expect(graphql_type.fields.keys).to match_array(%w[id isValid level])
        end

        it 'includes field descriptions' do
          expect(graphql_type.fields.values.last.description).to eq 'over 9000!'
        end
      end

      context 'when type has description' do
        it 'adds same description in graphql type' do
          expect(graphql_type.description).to eq 'Used for test purposes'
        end
      end

      context 'when model has custom name' do
        let(:model) do
          Class.new do
            include GraphqlRails::Model

            graphql do |c|
              c.name 'ChangedName'
            end

            def self.name
              'DummyModelWithCustomName'
            end
          end
        end

        it 'returns correct name' do
          expect(graphql_type.graphql_name).to eq 'ChangedName'
        end
      end

      it 'returns child class of graphql Object type' do
        expect(graphql_type < GraphQL::Schema::Object).to be true
      end
    end

    describe '#connection_type' do
      subject(:connection_type) { config.connection_type }

      context 'when model is simple ruby class' do
        it 'returns Conection' do
          expect(connection_type.graphql_name).to eq('DummyModelConnection')
        end
      end
    end

    describe '#input' do
      subject(:input) { config.input(:new_input) }

      context 'when config block is not given' do
        it 'raises error' do
          expect { input }
            .to raise_error('GraphQL input with name :new_input is not defined for DummyModel')
        end
      end

      context 'when config block is given' do
        subject(:input) do
          config.input(:new_input) do |c|
            c.attribute :name
          end
        end

        it 'returns input instance' do
          expect(input).to be_a(Model::Input)
        end

        context 'when block is given second time for same input' do
          before do
            config.input(:new_input) do |c|
              c.attribute :second_name
            end
          end

          it 'extends existing input' do
            expect(input.attributes.keys).to match_array(%w[name second_name])
          end
        end
      end
    end
  end
end
