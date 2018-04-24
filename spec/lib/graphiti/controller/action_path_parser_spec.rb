# frozen_string_literal: true

require 'spec_helper'
module Graphiti
  class DummyUser
    include Graphiti::Model
  end

  class Controller
    RSpec.describe ActionPathParser do
      class DummyUsersController < Graphiti::Controller; end

      subject(:parser) { described_class.new('dummy_users#create', module: 'graphiti/controller') }

      describe '#controller' do
        it 'returns correct controller class' do
          expect(parser.controller).to be(DummyUsersController)
        end
      end

      describe '#return_type' do
        context 'when action does not specify return type' do
          it 'generates type from controller model' do
            expect(parser.return_type).to eq(DummyUser.graphiti.graphql_type.to_non_null_type)
          end
        end
      end
    end
  end
end
