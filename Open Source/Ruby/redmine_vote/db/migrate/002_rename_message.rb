class RenameMessage < ActiveRecord::Migration
  def change
    rename_column :votes, :message_id, :issue_id
  end
end
