# frozen_string_literal: true

class CartDecorator < ApplicationDecorator
  delegate_all
  decorates_association :cart_items
end
