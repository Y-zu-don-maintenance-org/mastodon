# frozen_string_literal: true

class UnEmojiReactService < BaseService
  include Payloadable

  def call(account, status, emoji_reaction = nil)
    if emoji_reaction
      emoji_reaction.destroy!
      create_notification(emoji_reaction) if !status.account.local? && status.account.activitypub?
      notify_to_followers(emoji_reaction) if status.account.local?
    else
      bulk(account, status)
    end
    emoji_reaction
  end

  private

  def bulk(account, status)
    EmojiReaction.where(account: account).where(status: status).tap do |emoji_reaction|
      call(account, status, emoji_reaction)
    end
  end

  def create_notification(emoji_reaction)
    status = emoji_reaction.status
    ActivityPub::DeliveryWorker.perform_async(build_json(emoji_reaction), status.account_id, status.account.inbox_url)
  end

  def notify_to_followers(emoji_reaction)
    status = emoji_reaction.status
    ActivityPub::RawDistributionWorker.perform_async(build_json(emoji_reaction), status.account_id)
  end

  def build_json(emoji_reaction)
    # TODO: change to original serializer for other servers
    Oj.dump(serialize_payload(emoji_reaction, ActivityPub::UndoLikeSerializer))
  end
end
