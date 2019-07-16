# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

module GraphqlRails
  class Controller
    RSpec.describe RelationDecorator do
      subject(:relation_decorator) do
        described_class.new(relation: relation, decorator: decorator)
      end

      let(:decorator) do
        Class.new(SimpleDelegator) do
          def self.name
            'DummyDecorator'
          end
        end
      end

      let(:relation) do
        instance_double(
          ActiveRecord::Relation,
          first: record,
          to_a: [record, record2],
          where: inner_relation
        )
      end

      let(:inner_relation) { instance_double(ActiveRecord::Relation) }
      let(:record) { OpenStruct.new(name: 'John') }
      let(:record2) { OpenStruct.new(name: 'Jack') }

      describe '#first' do
        subject(:first) { relation_decorator.first }

        it 'returns instance of docorator' do
          expect(first).to be_a(decorator)
        end

        context 'when relation returns no record' do
          before do
            allow(relation).to receive(:first).and_return(nil)
          end

          it { is_expected.to be nil }
        end

        context 'when first is called with items count' do
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
      end
    end
  end
end
