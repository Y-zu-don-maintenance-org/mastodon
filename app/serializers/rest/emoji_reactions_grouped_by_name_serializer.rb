# frozen_string_literal: true

class REST::EmojiReactionsGroupedByNameSerializer < ActiveModel::Serializer
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
    object.respond_to?(:custom_emoji)
  end

  def account_ids?
    object.respond_to?(:account_ids)
  end
end
