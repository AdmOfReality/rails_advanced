# frozen_string_literal: true

class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user
    if user
      user.admin? ? admin_abilities : user_abilities
    else
      guest_abilities
    end
  end

  def guest_abilities
    can :read, :all
  end

  def admin_abilities
    can :manage, :all
  end

  def user_abilities
    guest_abilities
    can :me, User
    can :create, [Question, Answer, Comment, Subscription]
    can :update, [Question, Answer], author: user
    can :destroy, [Question, Answer, Subscription], author: user
    can :purge_attachment, [Question, Answer], author: user
    can :destroy_link, [Question, Answer], author: user
    can :best, Answer, question: { author_id: user.id }
  end
end
