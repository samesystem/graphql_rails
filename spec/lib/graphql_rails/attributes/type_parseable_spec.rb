# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe TypeParseable do
      subject(:parser) { parser_class.new(unparsed_type: unparsed_type) }

      let(:parser_class) do
        Class.new do
          include GraphqlRails::Attributes::TypeParseable

          attr_reader :unparsed_type

          def initialize(unparsed_type:)
            @unparsed_type = unparsed_type
          end
        end
      end

      let(:unparsed_type) { 'int!' }

      describe '#unwrapped_scalar_type' do
        subject(:unwrapped_scalar_type) { parser.unwrapped_scalar_type }

        context 'when "id" type is given' do
          let(:unparsed_type) { 'id!' }

          it { is_expected.to eq GraphQL::Types::ID }
        end

        context 'when "int" type is given' do
          let(:unparsed_type) { 'int!' }

          it { is_expected.to eq GraphQL::Types::Int }
        end

        context 'when "integer" type is given' do
          let(:unparsed_type) { 'integer!' }

          it { is_expected.to eq GraphQL::Types::Int }
        end

        context 'when "big_int" type is given' do
          let(:unparsed_type) { 'big_int!' }

          it { is_expected.to eq GraphQL::Types::BigInt }
        end

        context 'when "bigint" type is given' do
          let(:unparsed_type) { 'bigint!' }

          it { is_expected.to eq GraphQL::Types::BigInt }
        end

        context 'when "float" type is given' do
          let(:unparsed_type) { 'float!' }

          it { is_expected.to eq GraphQL::Types::Float }
        end

        context 'when "double" type is given' do
          let(:unparsed_type) { 'double!' }

          it { is_expected.to eq GraphQL::Types::Float }
        end

        context 'when "decimal" type is given' do
          let(:unparsed_type) { 'decimal!' }

          it { is_expected.to eq GraphQL::Types::Float }
        end

        context 'when "bool" type is given' do
          let(:unparsed_type) { 'bool!' }

          it { is_expected.to eq GraphQL::Types::Boolean }
        end

        context 'when "boolean" type is given' do
          let(:unparsed_type) { 'boolean!' }

          it { is_expected.to eq GraphQL::Types::Boolean }
        end

        context 'when "string" type is given' do
          let(:unparsed_type) { 'string!' }

          it { is_expected.to eq GraphQL::Types::String }
        end

        context 'when "str" type is given' do
          let(:unparsed_type) { 'str!' }

          it { is_expected.to eq GraphQL::Types::String }
        end

        context 'when "text" type is given' do
          let(:unparsed_type) { 'text!' }

          it { is_expected.to eq GraphQL::Types::String }
        end

        context 'when "date" type is given' do
          let(:unparsed_type) { 'date' }

          it { is_expected.to eq GraphQL::Types::ISO8601Date }
        end

        context 'when "time" type is given' do
          let(:unparsed_type) { 'time!' }

          it { is_expected.to eq GraphQL::Types::ISO8601DateTime }
        end

        context 'when "datetime" type is given' do
          let(:unparsed_type) { 'datetime!' }

          it { is_expected.to eq GraphQL::Types::ISO8601DateTime }
        end

        context 'when "date_time" type is given' do
          let(:unparsed_type) { '[DateTime!]' }

          it { is_expected.to eq GraphQL::Types::ISO8601DateTime }
        end

        context 'when "json" type is given' do
          let(:unparsed_type) { 'json!' }

          it { is_expected.to eq GraphQL::Types::JSON }
        end
      end
    end
  end
end
