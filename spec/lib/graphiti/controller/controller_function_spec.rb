# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Graphiti::Controller::ControllerFunction do
  subject(:function) { described_class.new(action_path, module: 'dummy/foo') }

  module Dummy
    module Foo
      class UsersController < Graphiti::Controller
        include Graphiti::Controller::CRUD

        def show
          render 'show:OK'
        end
      end
    end
  end

  let(:action_path) { 'users#show' }

  describe '#controller_class' do
    it 'returns correct controller class' do
      expect(function.send(:controller_class)).to be(Dummy::Foo::UsersController)
    end
  end

  describe '#call' do
    it 'triggers controller action' do
      expect(function.call(nil, nil, nil)).to eq 'show:OK'
    end
  end
end
