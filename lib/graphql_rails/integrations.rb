# frozen_string_literal: true

module GraphqlRails
  # allows to enable various integrations
  module Integrations
    def self.enable(*integrations)
      @enabled_integrations ||= []

      to_be_enabled_integrations = integrations.map(&:to_s) - @enabled_integrations

      to_be_enabled_integrations.each do |integration|
        require_relative "./integrations/#{integration}"
        Integrations.const_get(integration.classify).enable
      end

      @enabled_integrations += to_be_enabled_integrations
    end
  end
end
