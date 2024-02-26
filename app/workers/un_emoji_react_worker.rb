# frozen_string_literal: true

class UnEmojiReactWorker
  include Sidekiq::Worker

  def perform(account_id, status_id, emoji = nil)
    emoji_reaction = nil

    if emoji
      shortcode, domain = emoji.split('@')
      emoji_reaction = EmojiReaction.where(account_id: account_id).where(status_id: status_id).where(name: shortcode)
                                    .find { |reaction| domain == '' ? reaction.custom_emoji.nil? : reaction.custom_emoji&.domain == domain }
    end

    UnEmojiReactService.new.call(account_id.to_i, status_id.to_i, emoji_reaction)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
