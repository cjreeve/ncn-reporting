class Twin < ActiveRecord::Base
  belongs_to :issue
  belongs_to :twinned_issue, class_name: "Issue"


  after_create :create_inverse, unless: :has_inverse?
  after_destroy :destroy_inverses, if: :has_inverse?

  def create_inverse
    self.class.create(inverse_twin_options)
  end

  def destroy_inverses
    inverses.destroy_all
  end

  def has_inverse?
    self.class.exists?(inverse_twin_options)
  end

  def inverses
    self.class.where(inverse_twin_options)
  end

  def inverse_twin_options
    { twinned_issue_id: issue_id, issue_id: twinned_issue_id }
  end
end
