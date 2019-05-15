# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Router
    RSpec.describe PlainCursorEncoder do
      subject(:plain_cursor_encoder) { described_class }

      describe '.encode' do
        subject(:encode) { plain_cursor_encoder.encode(not_encoded_value, nil) }

        let(:not_encoded_value) { '123' }

        it 'does not modify original value' do
          expect(encode).to eq not_encoded_value
        end
      end

      describe '.decode' do
        subject(:decode) { plain_cursor_encoder.decode(encoded_value, nil) }

        let(:encoded_value) { '123' }

        it 'does not modify original value' do
          expect(decode).to eq encoded_value
        end
      end
    end
  end
end
