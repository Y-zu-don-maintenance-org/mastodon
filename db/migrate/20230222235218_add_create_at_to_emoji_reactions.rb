class AddCreateAtToEmojiReactions < ActiveRecord::Migration[6.1]
  def change
    add_column :emoji_reactions, :created_at, :timestamp
    add_column :emoji_reactions, :updated_at, :timestamp
  end
end
