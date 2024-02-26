# frozen_string_literal: true

class REST::NotifyEmojiReactionSerializer < ActiveModel::Serializer
  include RoutingHelper
  
  attributes :name

  attribute :count, if: :count?
  attribute :url, if: :custom_emoji?
  attribute :static_url, if: :custom_emoji?
  attribute :domain, if: :custom_emoji?

  def count?
    object.respond_to?(:count)
  end

  def custom_emoji?
    object.respond_to?(:custom_emoji) && object.custom_emoji.present?
  end

  def account_ids?
    object.respond_to?(:account_ids)
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
end
