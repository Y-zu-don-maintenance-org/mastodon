# frozen_string_literal: true

class Api::V1::Statuses::EmojiReactionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:emoji_reactions' }
  before_action :require_user!
  before_action :set_status, only: [:update]

  # For compatible with Fedibird API
  def update
    create_private
  end

  # TODO: destroy emoji reaction api
  def destroy
    # fav = current_account.favourites.find_by(status_id: params[:status_id])

    # if fav
    #  @status = fav.status
    #  UnfavouriteWorker.perform_async(current_account.id, @status.id)
    # else
    #  @status = Status.find(params[:status_id])
    #  authorize @status, :show?
    # end

    # render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_account.id, favourites_map: { @status.id => false })
    # rescue Mastodon::NotPermittedError
    not_found
  end

  private

  def create_private
    EmojiReactService.new.call(current_account, @status, params[:id])
    render json: @status, serializer: REST::StatusSerializer
  end

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
