class CreateEmojiReactions < ActiveRecord::Migration[6.1]
  def change
    create_table :emoji_reactions do |t|
      
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.belongs_to :status, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false, default: ''
      t.belongs_to :custom_emoji, foreign_key: { on_delete: :cascade }, index: false
      t.string :uri

    end
  end
end
