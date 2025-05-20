# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Service do
    let(:service_class) do
      Class.new do
        include GraphqlRails::Service

        attr_reader :args, :kwargs

        def initialize(*args, **kwargs)
          @args = args
          @kwargs = kwargs
        end

        def call
          { args: args, kwargs: kwargs }
        end
      end
    end

    describe '.call' do
      it 'instantiates service and calls instance method' do
        result = service_class.call('arg1', 'arg2', key1: 'value1', key2: 'value2')
        expect(result).to eq(args: %w[arg1 arg2], kwargs: { key1: 'value1', key2: 'value2' })
      end

      it 'works with empty kwargs' do
        result = service_class.call('arg1', 'arg2')
        expect(result).to eq(args: %w[arg1 arg2], kwargs: {})
      end

      it 'passes block to instance call method' do
        service_instance = instance_double(service_class)
        allow(service_class).to receive(:new).and_return(service_instance)
        allow(service_instance).to receive(:call).and_yield
        expect { |block| service_class.call(&block) }.to yield_control
      end
    end
  end
end
