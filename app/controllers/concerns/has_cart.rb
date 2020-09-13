# frozen_string_literal: true

module HasCart
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart, :cart_user_id

    private

    def set_cart_user_id
      id = nil
      
      if current_user
        id ||= current_user.id
      end

      if session[:cart_id]
        id ||= session[:cart_id]
      end

      unless id
        id = session[:cart_id] = SecureRandom.base64
      end

      id
    end

    def cart_user_id
      @cart_user_id ||= set_cart_user_id
    end

    def current_cart
      @current_cart ||= Cart.new(cart_user_id).decorate
    end
  end
end