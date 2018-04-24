# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module Graphiti
  RSpec.describe Model do
    class DummyModel
      include Graphiti::Model
    end

    subject(:model) { DummyModel }

    describe '.graphiti' do
      it 'returns model configuration' do
        expect(model.graphiti).to be_a(Model::Configuration)
      end
    end
  end
end
