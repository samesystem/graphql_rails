# frozen_string_literal: true

module Graphiti
  class Router
    def initialize
      yield(self) if block_given?
    end

    def resources(resources_name)
      name = resources_name.to_s

      resource(name.singulerize)

      query
    end

    def resource(resource_name)
      name = resource_name.to_s

      query(:find, on: :member, accepts: :id, resolver: FindByIdResolver.new(name))
      mutation(:create, sufix: name, on: :member, accepts: :all, resolver: CreateModelMigration.new(name))
      mutation(:update, sufix: name, on: :member, accepts: { all_except: [:id] }, resolver: CreateModelMigration.new(name))
      mutation(:destroy, sufix: name, on: :member, accepts: { all_except: [:id] }, resolver: CreateModelMigration.new(name))
    end

    def query(query_name, as: nil, suffix: nil, prefix: nil, on:, accepts:, resolver: nil)
      schema
    end
  end
end
