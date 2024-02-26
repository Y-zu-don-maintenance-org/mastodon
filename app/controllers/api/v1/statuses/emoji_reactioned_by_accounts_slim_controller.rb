# frozen_string_literal: true

class Api::V1::Statuses::EmojiReactionedByAccountsSlimController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:accounts' }
  before_action :set_status

  def index
    @accounts = load_emoji_reactions

    # TODO for serialize hash object
    render json: @accounts, each_serializer: REST::EmojiReactedBySlimSerializer
  end

  private

  def load_emoji_reactions
    @status.generate_emoji_reactions_grouped_by_account
  end

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
