# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe FindOrBuildGraphqlType do
      describe '.call' do
        subject(:call) do
          described_class.call(
            name: name,
            description: description,
            attributes: name.constantize.graphql.attributes,
            type_name: name.constantize.graphql.type_name,
            force_define_attributes: force_define_attributes
          )
        end

        let(:name) { 'DummyType' }
        let(:description) { 'This is my type!' }
        let(:force_define_attributes) { false }

        before do
          stub_const(name, dummy_model_class)
        end

        context 'when attribute does not have any arguments' do
          let(:dummy_model_class) do
            graphql_name = name
            graphql_description = description

            Class.new do
              include Model

              graphql do |c|
                c.name graphql_name
                c.description graphql_description
                c.attribute :name
              end
            end
          end

          it 'builds correct type' do
            expect(call.to_type_signature).to eq name
          end

          it 'builds type with correct fields' do
            expect(call.fields.keys).to match_array(%w[name])
          end

          it 'builds type without arguments' do
            expect(call.fields['name'].arguments).to be_empty
          end
        end

        context 'when attribute has arguments' do
          let(:dummy_model_class) do
            graphql_name = name
            graphql_description = description

            Class.new do
              include Model

              graphql do |c|
                c.name graphql_name
                c.description graphql_description
                c.attribute(:name).permit(length: :int!)
              end
            end
          end

          it 'builds correct type' do
            expect(call.to_type_signature).to eq name
          end

          it 'builds type with correct fields' do
            expect(call.fields.keys).to match_array(%w[name])
          end

          it 'builds type with correct arguments' do
            expect(call.fields['name'].arguments.keys).to match_array(%w[length])
          end
        end

        context 'when force redefine is required' do
          let(:dummy_model_class) do
            graphql_name = name
            graphql_description = description

            Class.new do
              include Model

              graphql do |c|
                c.name graphql_name
                c.description graphql_description

                c.attribute :name
              end
            end
          end

          before do
            described_class.call(
              name: name,
              description: description,
              attributes: {},
              type_name: name.constantize.graphql.type_name,
              force_define_attributes: false
            ) # Sets the type with zero fields
          end

          let(:force_define_attributes) { true }

          it 'builds type with correct fields count' do
            expect(call.fields.count).to eq(1)
          end
        end

        context 'when attribute is paginated' do
          let(:dummy_post_model_class) do
            Class.new do
              include GraphqlRails::Model

              graphql do |c|
                c.name 'Post'

                c.attribute(:title)
              end
            end
          end

          let(:dummy_model_class) do
            graphql_name = name
            graphql_description = description

            Class.new do
              include Model

              graphql do |c|
                c.name graphql_name
                c.description graphql_description

                c.attribute(:posts).type('[Post]').paginated
              end
            end
          end

          before do
            stub_const('Post', dummy_post_model_class)
          end

          it 'builds correct type' do
            expect(call.to_type_signature).to eq 'DummyType'
          end

          it 'builds type with correct fields' do
            expect(call.fields.keys).to match_array(%w[posts])
          end

          it 'builds type with pagination arguments' do
            expect(call.fields['posts'].arguments.keys).to match_array(%w[after before first last])
          end
        end
      end
    end
  end
end
