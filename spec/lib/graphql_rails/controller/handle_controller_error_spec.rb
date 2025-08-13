# frozen_string_literal: true

RSpec.describe GraphqlRails::Controller::HandleControllerError do
  describe '#call' do
    subject(:call) { described_class.new(error: error, controller: controller).call }

    let(:controller_class) do
      Class.new(GraphqlRails::Controller)
    end
    let(:controller) { controller_class.new(graphql_request) }
    let(:graphql_request) { GraphqlRails::Controller::Request.new(graphql_object, inputs, context) }
    let(:graphql_object) { double }
    let(:inputs) { { id: 1, firstName: 'John' } }
    let(:context) { double(add_error: nil) } # rubocop:disable RSpec/VerifiedDoubles

    let(:error) { StandardError.new('error') }

    before do
      allow(controller).to receive(:render).and_call_original
    end

    context 'when error is a GraphQL::ExecutionError' do
      let(:error) { GraphQL::ExecutionError.new('error') }

      it 'raises error' do
        expect { call }.to raise_error(error)
      end
    end

    context 'when error is not a GraphQL::ExecutionError' do
      it 'renders SystemError' do
        call

        expect(controller).to have_received(:render).with(error: GraphqlRails::SystemError.new(error))
      end
    end

    context 'when controller has custom error handler' do
      let(:handled_error_class) { Class.new(StandardError) }
      let(:error_class) { handled_error_class }
      let(:error) { error_class.new('error') }

      context 'when custom handler is a block' do
        let(:controller_class) do
          error_to_handle = handled_error_class

          Class.new(super()) do
            rescue_from(error_to_handle) { |error| render(error: error.message) }
          end
        end

        it 'renders error' do
          call

          expect(controller).to have_received(:render).with(error: error.message)
        end
      end

      context 'when custom handler is a method' do
        let(:controller_class) do
          error_to_handle = handled_error_class

          Class.new(super()) do
            rescue_from error_to_handle, with: :custom_handler

            def custom_handler
              render(error: 'custom error')
            end
          end
        end

        it 'renders error' do
          call

          expect(controller).to have_received(:render).with(error: 'custom error')
        end
      end

      context 'when custom handler raises error' do
        let(:controller_class) do
          error_to_handle = handled_error_class

          Class.new(super()) do
            rescue_from(error_to_handle) { |error| raise error }
          end
        end

        it 'renders SystemError' do
          call

          expect(controller).to have_received(:render).with(error: GraphqlRails::SystemError)
        end
      end
    end
  end
end
