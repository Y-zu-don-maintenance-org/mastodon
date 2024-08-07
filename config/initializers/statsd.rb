# frozen_string_literal: true

if ENV['STATSD_ADDR'].present?
  host, port = ENV['STATSD_ADDR'].split(':')

  begin
    statsd = Statsd.new(host, port)
    statsd.namespace = ENV.fetch('STATSD_NAMESPACE') { ['Mastodon', Rails.env].join('.') }

    NSA.inform_statsd(statsd) do |informant|
      informant.collect(:action_controller, :web)
      informant.collect(:active_record, :db)
      informant.collect(:active_support_cache, :cache)
      informant.collect(:sidekiq, :sidekiq)
    end
  rescue
    Rails.logger.warn("statsd address #{ENV['STATSD_ADDR']} not reachable, proceeding without statsd")
  end
end
