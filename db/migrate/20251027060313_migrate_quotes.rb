# frozen_string_literal: true

class MigrateQuotes < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          Status.where.not(quote_id: nil).unscope(:order).find_each do |status|
            next unless (quoted_status = Status.find_by(id: status.quote_id))

            Quote.create!(
              id: Mastodon::Snowflake.id_at(status.created_at),
              account_id: status.account_id,
              status:,
              quoted_status: quoted_status,
              quoted_account: quoted_status.account,
              approval_uri: nil,
              state: :accepted,
              created_at: status.created_at,
              updated_at: status.updated_at
            )
          end
        end

        dir.down do
          Quote.find_each do |quote|
            next unless quote.status.present? && quote.quoted_status.present? && quote.acceptable?

            quote.status.update!(quote_id: quote.quoted_status_id)
          end
        end
      end

      change_table :statuses do |t|
        t.remove_index :quote_id
        t.remove :quote_id, type: :bigint, null: true, default: nil
      end
    end
  end
end
