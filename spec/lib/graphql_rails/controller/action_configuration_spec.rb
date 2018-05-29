# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Controller
    RSpec.describe ActionConfiguration do
      subject(:config) { described_class.new }

      describe '#description' do
        context 'when some value is set' do
          it 'changes config description value' do
            expect { config.description('O hi!') }.to change(config, :description).to('O hi!')
          end

          it 'returns config object' do
            expect(config.description('O hi!')).to eq config
          end
        end

        context 'when no value is given' do
          before { config.description('test') }

          it 'returns description value' do
            expect(config.description).to eq 'test'
          end
        end
      end
    end
  end
end
