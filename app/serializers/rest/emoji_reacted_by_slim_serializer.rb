# frozen_string_literal: true

class REST::EmojiReactedBySlimSerializer < ActiveModel::Serializer

  belongs_to :account, serializer: REST::AccountSerializer
  has_many :emoji_reactions, serializer: REST::EmojiReactedBySlimReactionSerializer

  def attributes
    { account => emoji_reactions }
  end

  private

  def account
    object.first
  end

  def emoji_reactions
    object.last
  end
end
