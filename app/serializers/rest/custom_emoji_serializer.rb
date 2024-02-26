# frozen_string_literal: true

class REST::CustomEmojiSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :shortcode, :url, :static_url, :visible_in_picker

  attribute :category, if: :category_loaded?
  attribute :width, if: :width?
  attribute :height, if: :height?

  def url
    full_asset_url(object.image.url)
  end

  def static_url
    full_asset_url(object.image.url(:static))
  end

  def category
    object.category.name
  end

  def category_loaded?
    object.association(:category).loaded? && object.category.present?
  end

  def width?
    object.respond_to?(:image_width) || object.respond_to?(:width)
  end

  def height?
    object.respond_to?(:image_height) || object.respond_to?(:height)
  end

  def width
    object.respond_to?(:image_width) ? object.image_width : object.width
  end

  def height
    object.respond_to?(:image_height) ? object.image_height : object.height
  end
end
