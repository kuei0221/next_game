# frozen_string_literal: true

module CanGatherError
  extend ActiveSupport::Concern

  included do
    def gather_error!(object)
      return errors if object.errors.blank?

      errors.merge!(object.errors)
    end

    def child_valid?(object)
      return true if object.valid?

      gather_error!(object)
      false
    end
  end
end
