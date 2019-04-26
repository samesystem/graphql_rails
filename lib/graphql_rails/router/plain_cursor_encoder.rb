# frozen_string_literal: true

module GraphqlRail
  # simplest possible cursor encoder which returns element index
  module PlainCursorEncoder
    def self.encode(plain, _nonce)
      plain
    end

    def self.decode(plain, _nonce)
      plain
    end
  end
end
