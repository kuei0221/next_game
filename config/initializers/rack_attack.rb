# frozen_string_literal: true

module Rack
  class Attack
    ### Configure Cache ###

    # If you don't want to use Rails.cache (Rack::Attack's default), then
    # configure it here.
    #
    # Note: The store is only used for throttling (not blocklisting and
    # safelisting). It must implement .increment and .write like
    # ActiveSupport::Cache::Store

    Rack::Attack.cache.store = Redis.new(url: ENV['REDIS_URL'])

    class Request < ::Rack::Request
      # You many need to specify a method to fetch the correct remote IP address
      # if the web server is behind a load balancer.
      def remote_ip
        @remote_ip ||= (env['X-Real-IP'] || env['action_dispatch.remote_ip'] || ip).to_s
      end

      def allowed_ip?
        allowed_ips = ['127.0.0.1', '::1']
        allowed_ips.include?(remote_ip)
      end
    end

    safelist('allow from localhost', &:allowed_ip?)

    ### Throttle Spammy Clients ###

    # If any single client IP is making tons of requests, then they're
    # probably malicious or a poorly-configured scraper. Either way, they
    # don't deserve to hog all of the app server's CPU. Cut them off!
    #
    # Note: If you're serving assets through rack, those requests may be
    # counted by rack-attack and this throttle may be activated too
    # quickly. If so, enable the condition to exclude them from tracking.

    # Throttle all requests by IP (60rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    throttle('req/ip', limit: 100, period: 1.minute, &:ip)

    ### Prevent Brute-Force Login Attacks ###

    # The most common brute-force login attack is a brute-force password
    # attack where an attacker simply tries a large number of emails and
    # passwords to see if any credentials match.
    #
    # Another common method of attack is to use a swarm of computers with
    # different IPs to try brute-forcing a password for a specific account.

    # Throttle POST requests to /login by IP address
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
    throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if req.path == '/users/sign_in' && req.post?
    end

    # Throttle POST requests to /login by email param
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{normalized_email}"
    #
    # Note: This creates a problem where a malicious user could intentionally
    # throttle logins for another user and force their login requests to be
    # denied, but that's not very common and shouldn't happen to you. (Knock
    # on wood!)
    throttle('logins/email', limit: 5, period: 20.seconds) do |req|
      if req.path == '/users/sign_in' && req.post?
        # Normalize the email, using the same logic as your authentication process, to
        # protect against rate limit bypasses. Return the normalized email if present, nil otherwise.
        req.params['email'].to_s.downcase.gsub(/\s+/, '').presence
      end
    end

    ### Custom Throttle Response ###

    # By default, Rack::Attack returns an HTTP 429 for throttled responses,
    # which is just fine.
    #
    # If you want to return 503 so that the attacker might be fooled into
    # believing that they've successfully broken your app (or you just want to
    # customize the response), then uncomment these lines.
    # self.throttled_response = lambda do |env|
    #  [ 503,  # status
    #    {},   # headers
    #    ['']] # body
    # end

    blocklist('fail2ban') do |req|
      Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 0, findtime: 1.minute, bantime: 1.hour) do
        configuration.throttled?(req)
      end
    end
  end
end

ActiveSupport::Notifications.subscribe(/(throttle|blocklist).rack_attack/) do |_name, start, _finish, _request_id, payload|
  req = payload[:request]

  Rails.logger.info "[#{start.utc}] " \
                    "[Rack::Attack][#{req.env['rack.attack.match_type'].capitalize}] " \
                    "remote_ip=#{req.remote_ip}, " \
                    "path=#{req.fullpath}, " \
                    "method=#{req.request_method}"
end
