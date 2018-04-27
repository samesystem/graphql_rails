# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model do
    class DummyModel
      include GraphqlRails::Model
    end

    subject(:model) { DummyModel }

    describe '.graphql' do
      it 'returns model configuration' do
        expect(model.graphql).to be_a(Model::Configuration)
      end
    end
  end
end
