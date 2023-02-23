# frozen_string_literal: true

# == Schema Information
#
# Table name: emoji_reactions
#
#  id              :bigint(8)        not null, primary key
#  account_id      :bigint(8)        not null
#  status_id       :bigint(8)        not null
#  name            :string           default(""), not null
#  custom_emoji_id :bigint(8)
#  uri             :string
#  created_at      :datetime
#  updated_at      :datetime
#

class EmojiReaction < ApplicationRecord
    include Paginable
  
    update_index('statuses', :status)
  
    belongs_to :account,       inverse_of: :emoji_reactions
    belongs_to :status,        inverse_of: :emoji_reactions
    belongs_to :custom_emojis, optional: true
  
    has_one :notification, as: :activity, dependent: :destroy
  
    validates :status_id, uniqueness: { scope: :account_id }
  
    before_validation do
      self.status = status.reblog if status&.reblog?
    end
  
    after_destroy :invalidate_cleanup_info
  
    private
  
    def invalidate_cleanup_info
      return unless status&.account_id == account_id && account.local?
  
      account.statuses_cleanup_policy&.invalidate_last_inspected(status, :unfav)
    end
  end
  
