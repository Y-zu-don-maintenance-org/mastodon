# frozen_string_literal: true

class ActivityPub::UndoEmojiReactionSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor, :content

  has_one :object, serializer: ActivityPub::EmojiReactionSerializer

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#emoji_reactions/', object.id, '/undo'].join
  end

  def type
    'Undo'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def content
    object.custom_emoji.nil? ? object.name : ":#{object.name}:"
  end
end
