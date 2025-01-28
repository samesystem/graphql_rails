# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

module GraphqlRails
  RSpec.describe Decorator do
    let(:decorator_class) do
      Class.new do
        include GraphqlRails::Decorator

        attr_reader :args, :object

        def self.name
          'DummyDecorator'
        end

        def self.custom_build(object, *args)
          new(object, :custom, *args)
        end

        def initialize(object, *args)
          @object = object
          @args = args
        end
      end
    end

    describe '.decorate' do
      subject(:decorate) { decorator_class.decorate(object, *decorator_args) }

      let(:object) { double('Something') } # rubocop:disable RSpec/VerifiedDoubles
      let(:decorator_args) { nil }

      context 'when object is not array and not nil' do
        it 'returns decorator instance' do
          expect(decorate).to be_a(decorator_class)
        end
      end

      context 'when arguments are given' do
        let(:decorator_args) { %w[arg1 arg2] }

        it 'creates decorator with given args' do
          expect(decorate.args).to eq(decorator_args)
        end
      end

      context 'when custom build method is provided' do
        subject(:decorate) { decorator_class.decorate(object, *decorator_args, build_with: :custom_build) }

        let(:decorator_args) { %w[arg1 arg2] }

        it 'uses custom build method' do
          expect(decorate.args).to eq([:custom] + decorator_args)
        end
      end

      context 'when object is nil' do
        let(:object) { nil }

        it { is_expected.to be_nil }
      end

      context 'when object is instance of ActiveRecord::Relation' do
        let(:object) { instance_double(ActiveRecord::Relation) }

        before do
          allow(object).to receive(:is_a?).with(ActiveRecord::Relation).and_return(true)
        end

        it 'returns RelationDecorator instance' do
          expect(decorate).to be_a(Decorator::RelationDecorator)
        end
      end

      context 'when object is an Array' do
        let(:object) { ['a'] }

        it 'returns array of decorator instances' do
          expect(decorate).to all be_a(decorator_class)
        end
      end
    end
  end
end
