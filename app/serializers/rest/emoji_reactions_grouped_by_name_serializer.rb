# frozen_string_literal: true

#   name: string,
#count: number,
#account_ids: Array<string>,
#me: boolean,
#url: string,
#domain: string

class REST::EmojiReactionsGroupedByNameSerializer < ActiveModel::Serializer
    attributes :name, :count
  
    attribute :me, if: :current_user?
    attribute :url, if: :custom_emoji?
    attribute :static_url, if: :custom_emoji?
    attribute :domain, if: :custom_emoji?
    attribute :account_ids, if: :has_account_ids?

    def current_user?
        !current_user.nil?
    end

    def custom_emoji?
        object.respond_to?(:custom_emoji)
    end

    def has_account_ids?
        object.respond_to?(:account_ids)
    end
end
  