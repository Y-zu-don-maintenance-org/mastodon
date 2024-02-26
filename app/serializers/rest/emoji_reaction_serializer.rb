# frozen_string_literal: true

class REST::EmojiReactionSerializer < ActiveModel::Serializer
  attributes :name

  attribute :count, if: :count?
  attribute :url, if: :custom_emoji?
  attribute :static_url, if: :custom_emoji?
  attribute :domain, if: :custom_emoji?
  attribute :account_ids, if: :account_ids?

  def count?
    object.respond_to?(:count)
  end

  def custom_emoji?
    object.respond_to?(:url)
  end

  def account_ids?
    object.respond_to?(:account_ids)
  end
end
