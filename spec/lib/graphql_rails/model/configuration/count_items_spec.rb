# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

class GraphqlRails::Model::Configuration
  RSpec.describe CountItems do
    subject(:count_items) { described_class.new(graphql_object, nil, nil) }

    let(:graphql_object) { double('GraphqlObject', nodes: items) } # rubocop:disable RSpec/VerifiedDoubles

    describe '.call' do
      subject(:call) { described_class.call(graphql_object, nil, nil) }

      context 'when items are instance of ActiveRecord::Relation' do
        let(:items) { instance_double(ActiveRecord::Relation, size: 5) }

        before do
          allow(items).to receive(:is_a?).with(ActiveRecord::Relation).and_return(true)
          allow(items).to receive(:except).and_return(items)
        end

        it 'excludes offset' do
          call
          expect(items).to have_received(:except).with(:offset)
        end

        it 'returns correct items number' do
          expect(call).to eq 5
        end
      end

      context 'when items are not instance of ActiveRecord::Relation' do
        let(:items) { %i[a b c] }

        it 'returns correct items count' do
          expect(call).to eq items.count
        end
      end
    end
  end
end
