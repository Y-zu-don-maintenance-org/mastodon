# frozen_string_literal: true

class REST::NotificationSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at

  belongs_to :from_account, key: :account, serializer: REST::AccountSerializer
  belongs_to :target_status, key: :status, if: :status_type?, serializer: REST::StatusSerializer
  belongs_to :report, if: :report_type?, serializer: REST::ReportSerializer
  belongs_to :emoji_reaction, if: :emoji_reaction_type?, serializer: REST::EmojiReactionSerializer

  def id
    object.id.to_s
  end

  def status_type?
    [:favourite, :emoji_reaction, :reblog, :status, :mention, :poll, :update].include?(object.type)
  end

  def report_type?
    object.type == :'admin.report'
  end

  def emoji_reaction_type?
    object.type == :emoji_reaction
  end
end
