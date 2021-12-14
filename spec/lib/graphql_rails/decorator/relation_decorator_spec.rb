# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

module GraphqlRails
  module Decorator
    RSpec.describe RelationDecorator do
      subject(:relation_decorator) do
        described_class.new(
          relation: relation,
          decorator: decorator,
          decorator_args: decorator_args
        )
      end

      shared_examples 'single decorated relation result' do |method_name|
        it 'returns instance of decorator' do
          expect(subject).to be_a(decorator)
        end

        context 'when relation returns no record' do
          before do
            allow(relation).to receive(method_name).and_return(nil)
          end

          it { is_expected.to be nil }
        end
      end

      let(:decorator) do
        Class.new(SimpleDelegator) do
          attr_reader :args

          def initialize(object, *args)
            super(object)
            @args = args
          end

          def self.name
            'DummyDecorator'
          end
        end
      end

      let(:relation) do
        instance_double(
          ActiveRecord::Relation,
          find: record,
          second: record,
          last: record,
          find_by: record,
          first: record,
          to_a: [record, record2],
          where: inner_relation
        )
      end

      let(:decorator_args) { ['arg1'] }
      let(:inner_relation) { instance_double(ActiveRecord::Relation) }
      let(:record) { OpenStruct.new(name: 'John') }
      let(:record2) { OpenStruct.new(name: 'Jack') }

      describe '#find' do
        subject(:find) { relation_decorator.find(1) }

        it_behaves_like 'single decorated relation result', :find
      end

      describe '#find_by' do
        subject(:find_by) { relation_decorator.find_by(id: 1) }

        it_behaves_like 'single decorated relation result', :find_by
      end

      describe '#second' do
        subject(:second) { relation_decorator.second }

        it_behaves_like 'single decorated relation result', :second
      end

      describe '#last' do
        subject(:last) { relation_decorator.last }

        it_behaves_like 'single decorated relation result', :last
      end

      describe '#first' do
        subject(:first) { relation_decorator.first }

        it_behaves_like 'single decorated relation result', :first

        context 'when `first` is called with items count' do
          subject(:first) { relation_decorator.first(2) }

          before do
            allow(relation).to receive(:first).with(2).and_return([record, record2])
          end

          it 'returns decorated list' do
            expect(first).to all be_a(decorator)
          end
        end
      end

      describe '#where' do
        let(:where) { relation_decorator.where(name: 'John') }

        it 'returns instance of relation decorator' do
          expect(where).to be_a(described_class)
        end
      end

      describe '#find_each' do
        before do
          allow(relation).to receive(:find_each)
            .and_yield(record)
            .and_yield(record2)
        end

        it 'returns instance of relation decorator' do
          relation_decorator.find_each do |decorated_item|
            expect(decorated_item).to be_a(decorator)
          end
        end
      end

      describe '#to_a' do
        subject(:to_a) { relation_decorator.to_a }

        it 'returns list of decorated items' do
          expect(to_a).to all be_a(decorator)
        end

        it 'decorates instances with given arguments' do
          expect(to_a.first.args).to eq(decorator_args)
        end
      end
    end
  end
end
