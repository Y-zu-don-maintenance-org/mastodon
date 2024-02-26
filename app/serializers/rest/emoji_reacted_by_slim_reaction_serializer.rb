# frozen_string_literal: true

class REST::EmojiReactedBySlimReactionSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name

  attribute :url, if: :custom_emoji?
  attribute :static_url, if: :custom_emoji?
  attribute :domain, if: :custom_emoji?

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
