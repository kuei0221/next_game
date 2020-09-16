# frozen_string_literal: true

require 'aws-sdk-s3'

credential = Aws::Credentials.new(
  access_key_id = Rails.application.credentials.dig(:aws, :access_key_id),
  secret_access_key = Rails.application.credentials.dig(:aws, :secret_access_key)
)

Aws.config.update({ region: ENV['AWS_REGION'], credentials: credential })
