class AddressPolicy < ApplicationPolicy
  def show?
    return true
  end

  def create?
    return true
  end

  def update?
    # return true if user.admin?
    # return true if record.id == user.id
    return true
  end

  def destroy?
    # return true if user.admin?
    # return true if record.id == user.id
    return true
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end