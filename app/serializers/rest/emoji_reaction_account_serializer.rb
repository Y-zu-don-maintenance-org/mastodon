# frozen_string_literal: true

class REST::EmojiReactionAccountSerializer < ActiveModel::Serializer
  include RoutingHelper
  include FormattingHelper

  attributes :id, :name

  attribute :url, if: :custom_emoji?
  attribute :static_url, if: :custom_emoji?
  attribute :domain, if: :custom_emoji?

  belongs_to :account, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end

  def url
    full_asset_url(object.custom_emoji.image.url)
  end

  def static_url
    full_asset_url(object.custom_emoji.image.url(:static))
  end

  def domain
    object.custom_emoji.domain
  end

  def custom_emoji?
    object.custom_emoji.present?
  end
end
