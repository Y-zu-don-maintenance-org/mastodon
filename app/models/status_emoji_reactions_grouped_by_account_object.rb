class StatusEmojiReactionsGroupedByAccountObject
  def initialize(account, emoji_reactions)
    @account = account
    @emoji_reactions = emoji_reactions
  end

  def read_attribute_for_serialization(_)
    REST::EmojiReactedBySlimSerializer
  end

  def model_name
    'EmojiReaction'
  end
end
