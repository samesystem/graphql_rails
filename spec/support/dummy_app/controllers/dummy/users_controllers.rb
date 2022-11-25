# frozen_string_literal: true

require_relative '../../models/dummy/user'

module Dummy
  class UsersController < GraphqlRails::Controller
    action(:show)
      .permit(id: 'ID!')
      .returns(::Dummy::User.to_s)

    def show
      User.new(name: 'John')
    end
  end
end
