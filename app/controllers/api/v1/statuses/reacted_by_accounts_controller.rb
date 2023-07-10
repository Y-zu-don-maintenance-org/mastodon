# frozen_string_literal: true

class Api::V1::Statuses::ReactedByAccountsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:accounts' }
  before_action :set_status
  after_action :insert_pagination_headers

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def load_accounts
    scope = default_accounts
    scope = scope.where.not(id: current_account.excluded_from_timeline_account_ids) unless current_account.nil?
    scope.merge(paginated_reactions).to_a
  end

  def default_accounts
    Account
      .without_suspended
      .includes(:reactions, :account_stat)
      .references(:reactions)
      .where(reactions: { status_id: @status.id })
  end

  def paginated_reactions
    Reaction.paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_status_reacted_by_index_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @accounts.empty?
      api_v1_status_reacted_by_index_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @accounts.last.reactions.last.id
  end

  def pagination_since_id
    @accounts.first.reactions.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
