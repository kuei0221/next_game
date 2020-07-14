# frozen_string_literal: true

class MyFailureApp < Devise::FailureApp
  
  def respond
    print 'my failure app is loaded'
    case request.format.symbol
    when :json
      json_failure
    when :js
      js_failure
    else
      super
    end
  end

  def js_failure
    self.status = 401
    self.content_type = 'application/js'
    flash.alert = 'You need to sign in or sign up before continuing.'
  end

  def json_failure
    self.status = 401
    self.content_type = 'application/json'
    self.response_body = "{'error' : 'authentication error'}"
  end
end