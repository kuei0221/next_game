# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  it { should belong_to(:order).class_name('Order').with_foreign_key(:order_id)}
end