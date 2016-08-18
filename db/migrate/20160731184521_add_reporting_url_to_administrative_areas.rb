class AddReportingUrlToAdministrativeAreas < ActiveRecord::Migration
  def change
    add_column :administrative_areas, :reporting_url, :string
  end
end
