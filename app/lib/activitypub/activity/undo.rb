# frozen_string_literal: true

class ActivityPub::Activity::Undo < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Announce'
      undo_announce
    when 'Accept'
      undo_accept
    when 'Follow'
      undo_follow
    when 'Like'
      undo_like
    when 'Block'
      undo_block
    when nil
      handle_reference
    end
  end

  private

  def handle_reference
    # Some implementations do not inline the object, and as we don't have a
    # global index, we have to guess what object it is.
    return if object_uri.nil?

    try_undo_announce || try_undo_accept || try_undo_follow || try_undo_like || try_undo_block || delete_later!(object_uri)
  end

  def try_undo_announce
    status = Status.where.not(reblog_of_id: nil).find_by(uri: object_uri, account: @account)
    if status.present?
      RemoveStatusService.new.call(status)
      true
    else
      false
    end
  end

  def try_undo_accept
    # We can't currently handle `Undo Accept` as we don't record `Accept`'s uri
    false
  end

  def try_undo_follow
    follow = @account.follow_requests.find_by(uri: object_uri) || @account.active_relationships.find_by(uri: object_uri)

    if follow.present?
      follow.destroy
      true
    else
      false
    end
  end

  def try_undo_like
    # There is an index on accounts, but an account may have *many* favs, so this may be too costly
    false
  end

  def try_undo_block
    block = @account.block_relationships.find_by(uri: object_uri)
    if block.present?
      UnblockService.new.call(@account, block.target_account)
      true
    else
      false
    end
  end

  def undo_announce
    return if object_uri.nil?

    status   = Status.find_by(uri: object_uri, account: @account)
    status ||= Status.find_by(uri: @object['atomUri'], account: @account) if @object.is_a?(Hash) && @object['atomUri'].present?

    if status.nil?
      delete_later!(object_uri)
    else
      RemoveStatusService.new.call(status)
    end
  end

  def undo_accept
    ::Follow.find_by(target_account: @account, uri: target_uri)&.revoke_request!
  end

  def undo_follow
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    if @account.following?(target_account)
      @account.unfollow!(target_account)
    elsif @account.requested?(target_account)
      FollowRequest.find_by(account: @account, target_account: target_account)&.destroy
    else
      delete_later!(object_uri)
    end
  end

  def undo_like_original
    status = status_from_uri(target_uri)

    return if status.nil? || !status.account.local?

    if @account.favourited?(status)
      favourite = status.favourites.where(account: @account).first
      favourite&.destroy
    else
      delete_later!(object_uri)
    end
  end

  def undo_like
    @original_status = status_from_uri(target_uri)

    return if @original_status.nil?

    if shortcode.present?
      emoji_tag = @object['tag'].is_a?(Array) ? @object['tag']&.first : @object['tag']

      if emoji_tag.present? && emoji_tag['id'].present?
        emoji = CustomEmoji.find_by(shortcode: shortcode, domain: @account.domain)
      end

      if @account.reacted?(@original_status, shortcode, emoji)
        @original_status.emoji_reactions.where(account: @account, name: shortcode, custom_emoji: emoji).first&.destroy

        if @original_status.account.local?
          forward_for_undo_emoji_reaction
          relay_for_undo_emoji_reaction
        end
      else
        delete_later!(object_uri)
      end
    else
      undo_like_original
    end
  end

  def write_stream(emoji_reaction)
    emoji_group = @original_status.emoji_reactions_grouped_by_name
                                  .find { |reaction_group| reaction_group['name'] == emoji_reaction.name && (!reaction_group.key?(:domain) || reaction_group['domain'] == emoji_reaction.custom_emoji&.domain) }
    if emoji_group
      emoji_group['status_id'] = @original_status.id.to_s
    else
      # name: emoji_reaction.name, count: 0, domain: emoji_reaction.domain
      emoji_group = { 'name' => emoji_reaction.name, 'count' => 0, 'account_ids' => [], 'status_id' => @status.id.to_s }
      emoji_group['domain'] = emoji_reaction.custom_emoji.domain if emoji_reaction.custom_emoji
    end
    FeedAnyJsonWorker.perform_async(render_emoji_reaction(emoji_group), @original_status.id, emoji_reaction.account_id)
  end

  def render_emoji_reaction(emoji_group)
    @render_emoji_reaction ||= Oj.dump(event: :emoji_reaction, payload: emoji_group.to_json)
  end

  def forward_for_undo_emoji_reaction
    return unless @json['signature'].present?

    ActivityPub::RawDistributionWorker.perform_async(Oj.dump(@json), @original_status.account.id, [@account.preferred_inbox_url])
  end

  def relay_for_undo_emoji_reaction
    return unless @json['signature'].present? && @original_status.public_visibility?

    ActivityPub::DeliveryWorker.push_bulk(Relay.enabled.pluck(:inbox_url)) do |inbox_url|
      [Oj.dump(@json), @original_status.account.id, inbox_url]
    end
  end

  def shortcode
    return @shortcode if defined?(@shortcode)

    @shortcode = begin
      if @object['_misskey_reaction'] == '⭐'
        nil
      else
        @object['content']&.delete(':')
      end
    end
  end

  def undo_block
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    if @account.blocking?(target_account)
      UnblockService.new.call(@account, target_account)
    else
      delete_later!(object_uri)
    end
  end

  def target_uri
    @target_uri ||= value_or_id(@object['object'])
  end
end
