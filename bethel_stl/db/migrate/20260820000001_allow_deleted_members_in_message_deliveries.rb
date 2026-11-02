class AllowDeletedMembersInMessageDeliveries < ActiveRecord::Migration[8.1]
  def change
    change_column_null :message_deliveries, :member_id, true
  end
end
