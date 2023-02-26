# frozen_string_literal: true

class FeedAnyJsonWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable
  include AccountLimitable

  def perform(payload_json, status_id, my_account_id = nil)
    redis.publish("timeline:#{my_account_id}", payload_json) if my_account_id.present?

    status = Status.find(status_id.to_i)

    if status.present?
      scope_status(status).find_each do |account_id|
        p account_id if redis.exists?("subscribed:timeline:#{account_id}")
        redis.publish("timeline:#{account_id}", payload_json) if redis.exists?("subscribed:timeline:#{account_id}")
      end
    end

    true
  rescue ActiveRecord::RecordNotFound
    true
  end
end
