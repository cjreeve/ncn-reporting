class AddAdministrativeAreaReferenceToIssues < ActiveRecord::Migration
  def change
    add_reference :issues, :administrative_area, index: true
  end
end
