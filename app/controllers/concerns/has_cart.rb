# frozen_string_literal: true

module HasCart
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart

    private

    def current_cart
      @current_cart ||= Cart.new(current_user.id).decorate
    end
  end
end
