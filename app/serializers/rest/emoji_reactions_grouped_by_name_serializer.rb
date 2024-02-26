# frozen_string_literal: true

class REST::EmojiReactionsGroupedByNameSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name, :count

  attribute :me, if: :current_user?
  attribute :url, if: :custom_emoji?
  attribute :static_url, if: :custom_emoji?
  attribute :domain, if: :custom_emoji?
  attribute :account_ids, if: :account_ids?

  def current_user?
    !current_user.nil?
  end

  def custom_emoji?
    object.custom_emoji.present?
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
