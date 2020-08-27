# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

Rails.logger =  ActiveSupport::Logger.new(Rails.root.join('log', "#{ Rails.env }.log") )

# Initialize the Rails application.
Rails.application.initialize!
