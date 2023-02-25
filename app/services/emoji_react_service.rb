# frozen_string_literal: true

class EmojiReactService < BaseService
  include Authorization
  include Payloadable

  # React a status with emoji and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @param [string] name
  # @return [Favourite]
  def call(account, status, name)
    authorize_with account, status, :emoji_reaction?

    emoji_reaction = EmojiReaction.find_by(account: account, status: status, name: name)

    return emoji_reaction unless emoji_reaction.nil?

    shortcode, domain = name.split('@')

    custom_emoji = CustomEmoji.find_by(shortcode: shortcode, domain: domain)

    emoji_reaction = EmojiReaction.create!(account: account, status: status, name: shortcode, custom_emoji: custom_emoji)

    Trends.statuses.register(status)

    create_notification(emoji_reaction)
    notify_to_followers(emoji_reaction)
    bump_potential_friendship(account, status)

    emoji_reaction
  end

  private

  def create_notification(emoji_reaction)
    status = emoji_reaction.status

    if status.account.local?
      # TODO: Change favourite event to notify
      LocalNotificationWorker.perform_async(status.account_id, emoji_reaction.id, 'Favourite', 'favourite')
    elsif status.account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(emoji_reaction), emoji_reaction.account_id, status.account.inbox_url)
    end
  end

  def notify_to_followers(emoji_reaction)
    status = emoji_reaction.status

    return unless status.account.local?

    ActivityPub::RawDistributionWorker.perform_async(build_json(emoji_reaction), status.account_id)
  end

  def broadcast_updates!(emoji_reaction)
    status = emoji_reaction.status

    DistributionWorker.perform_async(status.id, { 'update' => true })
  end

  def bump_potential_friendship(account, status)
    ActivityTracker.increment('activity:interactions')
    return if account.following?(status.account_id)

    PotentialFriendshipTracker.record(account.id, status.account_id, :emoji_reaction)
  end

  def build_json(emoji_reaction)
    # TODO: change to original serializer for other servers
    Oj.dump(serialize_payload(emoji_reaction, ActivityPub::LikeSerializer))
  end
end
