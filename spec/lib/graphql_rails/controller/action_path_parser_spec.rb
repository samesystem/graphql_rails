# frozen_string_literal: true

require 'spec_helper'
module GraphqlRails
  class DummyUser
    include GraphqlRails::Model
  end

  class Controller
    RSpec.describe ActionPathParser do
      class DummyUsersController < GraphqlRails::Controller; end

      subject(:parser) { described_class.new('dummy_users#create', module: 'graphql_rails/controller') }

      describe '#controller' do
        it 'returns correct controller class' do
          expect(parser.controller).to be(DummyUsersController)
        end
      end

      describe '#return_type' do
        context 'when action does not specify return type' do
          it 'generates type from controller model' do
            expect(parser.return_type).to eq(DummyUser.graphql.graphql_type.to_non_null_type)
          end
        end
      end
    end
  end
end
