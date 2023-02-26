# frozen_string_literal: true

class REST::EmojiReactionSerializer < ActiveModel::Serializer
  attributes :name, :count

  attribute :url, if: :custom_emoji?
  attribute :static_url, if: :custom_emoji?
  attribute :domain, if: :custom_emoji?
  attribute :account_ids, if: :account_ids?

  def custom_emoji?
    object.url.present?
  end

  def account_ids?
    object.respond_to?(:account_ids)
  end
end
