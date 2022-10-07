# frozen_string_literal: true

module Dummy
  class User
    include GraphqlRails::Model

    graphql do |c|
      c.name("DummyUser#{SecureRandom.hex}")

      c.attribute :name
    end

    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end
end
