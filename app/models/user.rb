class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include Geocodeable

  ROLES = %w[staff coordinator ranger volunteer guest]

  has_one :image, as: :owner, dependent: :destroy

  has_many :issues
  has_many :comments
  has_many :user_managed_route_selections
  has_many :routes, through: :user_managed_route_selections
  has_many :user_managed_group_selections
  has_many :groups, through: :user_managed_group_selections

  has_many :user_admin_area_selections
  has_many :administrative_areas, through: :user_admin_area_selections
  has_many :user_label_selections
  has_many :labels, through: :user_label_selections
  has_many :issue_follower_selections
  has_many :interests, through: :issue_follower_selections, source: :issue

  has_many :user_accounts, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :creator, class_name: 'User'

  belongs_to :region

  validates :region, presence: true
  validates :name, length: { in: 2..80 }, uniqueness: true
  validates :email, presence: true
  validates :role, presence: true

  attr_reader :administrative_area_tokens

  before_validation do
    self.issue_filter_mode = 'regional' unless %w(national regional customised).include?(self.issue_filter_mode)
  end

  scope :active, -> { where(is_locked: false) }

  def administrative_area_tokens=(ids)
    ids_array = ids&.split(",")&.collect(&:to_i)
    if ids_array && ids_array[0].to_i > 0
      self.administrative_area_ids = ids_array
    end
  end

  accepts_nested_attributes_for(
    :image,
    allow_destroy: true,
    reject_if:  proc { |a| a[:src].blank? }
  )


  ### public methods ###

  def first_name
    self.name.split(' ').first
  end

  def stripper_name(strip_role = true)
    strip_role ? self.name.gsub('(sustrans)','') : self.name
  end

  def removable?
    self.issues.limit(1).blank? && self.comments.limit(1).blank?
  end

  def ranger_like?
    %w{ranger coordinator}.include? role
  end

  def guest?
    role == 'guest'
  end

  def volunteer?
    role == 'volunteer'
  end

  def ranger?
    role == 'ranger'
  end

  def coordinator?
    role == 'coordinator'
  end

  def staff?
    role == 'staff'
  end

  def active?
    !is_locked
  end

  def image_url(version = nil)
    if self.image.present?
      version ? self.image.src_url(version) : self.image.src
    else
      'missing-profile-picture.svg'
    end
  end

  def can_view_email?(user)
    self.role == "staff" || user.role == "staff" || self.is_admin? || user == self
  end

  # notification methods

  def own_draft_issue_count
    Issue.where(user: self, state: 'draft').count
  end

  def own_issue_resolved_count
    Issue.where(state: 'resolved', user: self).count
  end

  def own_issue_unsolvable_count
    Issue.where(state: 'unsolvable', user: self).count
  end

  # TODO - how to show other route or group 'submitted' notifications for volunteer coordinator?
  def user_submitted_issue_count(user_areas = self.administrative_areas.to_a, user_routes = self.routes.to_a)
    if self.ranger_like? && user_areas.present?
      options = { state: 'submitted', administrative_area: user_areas }
      options[:route] = user_routes if user_routes.present?
      Issue.where(options).count
    else
      0
    end
  end

  # TODO - how to show other route or group 'resolved' notifications for volunteer coordinator?
  def user_resolved_issue_count(user_areas = self.administrative_areas.to_a, user_routes = self.routes.to_a)
    if self.ranger_like? && user_areas.present?
      options = { state: 'resolved', administrative_area: user_areas }
      options[:route] = user_routes if user_routes.present?
      Issue.where(options).count
    else
      0
    end
  end


  def open_label_counts(user_labels = self.labels, user_areas = self.administrative_areas.to_a, user_routes = self.routes.to_a)
    # TODO - how to show 'other' route or group 'open' notifications for volunteer coordinator?
    open_label_counts = {}
    user_labels.each do |label|
      options = {state: ["open", "reopened"]}
      options[:labels] = {name: label.name}
      options[:administrative_area] = user_areas if user_areas.present? && !(user_areas.one? && user_areas.first.name.downcase == "other")
      options[:route] =  user_routes if user_routes.present? && !(user_routes.one? && user_routes.first.name.downcase == "other")
      label_key = label.name.parameterize.to_sym
      open_label_counts[label_key] = Issue.joins(:labels).where(options).distinct.count
    end
    open_label_counts
  end

end
