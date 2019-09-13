class Ability
  include CanCan::Ability

  def initialize(user)

    if user.role == 'super'
      can :manage, :all
    end

    if user.role == 'tester'
      can :read, :all
      can :manage,  Message
      can :manage,  SeparateMessage
      can :manage,  LastInlineButton
      cannot :delete, :all
    end

    if user.role == 'manager'
      can :read, :all
      can :manage,  Message
      can :manage,  SeparateMessage
      can :manage,  LastInlineButton
      cannot :delete, :all
    end

  end
end
