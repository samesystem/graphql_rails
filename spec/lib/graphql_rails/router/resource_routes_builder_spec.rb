# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Router::ResourceRoutesBuilder do
    subject(:builder) { described_class.new(:users, on: :member) }

    describe '#routes' do
      context 'when default options includes "on"' do
        it 'generates index as collection routes' do
          index_route = builder.routes.detect { |route| route.path == 'users#index' }

          expect(index_route).to be_collection
        end
      end
    end
  end
end
