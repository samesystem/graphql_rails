# frozen_string_literal: true

require 'spec_helper'

module Graphiti
  RSpec.describe Controller::Configuration do
    class DummyController < Controller
      action(:some_method).permit(:id)
      def some_method; end

      action(:some_other_method).permit(:id, :name)
      def some_other_method; end
    end

    subject(:configuration) { DummyController.controller_configuration }

    let(:controller) { DummyController }

    describe '#action' do
      it 'returns hash with specified acceptable arguments' do
        expect(configuration.action(:some_method).attributes.keys).to match_array(%w[id])
      end
    end
  end
end
