class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    can :manage, :all if user.is_admin? && !user.is_locked?

    if (user.role == "staff") && !user.is_locked?
      can :read, Region
      can :manage, Issue
      can :search, Issue
      can :manage, Group
      can :manage, Category
      can :manage, Image
      can :manage, Problem
      can :manage, Route
      can :manage, AdministrativeArea
      can :read, User
      can :update, User, id: user.id
      can :manage, Comment
      can :manage, Page, role: ["volunteer", "ranger", "staff"]
      can :create, Page
      can :read, Page
      can :manage, Label
      can :manage, Site
      can :read, Update
    end

    if %w{coordinator ranger}.include?(user.role) && !user.is_locked?
      can :read, Region
      can [:read, :create, :edit, :update, :progress], Issue
      can [:destroy], Issue, user_id: user.id
      can :search, Issue
      can :read, Category
      can :manage, Problem
      can :manage, AdministrativeArea
      can :read, User
      can :manage, User, id: user.id
      can :manage, Comment, user_id: user.id
      can :manage, Page, role: ["volunteer", "ranger"]
      can :read, Page
      can :read, Route
      can :read, Label
      can :manage, Site
      can :read, Update
    end

    if (user.role == "volunteer") && !user.is_locked?
      can :read, Region
      can [:read, :create, :edit, :update, :progress], Issue
      can [:destroy], Issue, user_id: user.id
      can :search, Issue
      can :read, User
      can :update, User, id: user.id
      can :manage, Comment, user_id: user.id
      can :manage, Page, role: "volunteer"
      can :read, Page
      can :manage, Route
      can :manage, Site
      can :read, Update
    end

    if (user.role == "guest") && !user.is_locked?
      can :read, Region
      can :read, Issue
      can :destroy, Issue, user_id: user.id
      can :search, Issue
      can :manage, Site
      can :read, User, role: 'staff'
    end

    can :manage, Site

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
