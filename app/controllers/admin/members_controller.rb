class Admin::MembersController < Admin::IndexController
  def self.permission_definition
  end

  def add
    redirect_if_fail(rank.can_execute?(current_user, :members, :add), admin_ranks_url, :action); return if performed?
    user = User.where(:username => params[:user]).first
    unless user
      flash[:alert] = 'User not found'
      redirect_to [:admin, rank]
      return
    end
    unless rank.members.exists?(user.id)
      rank.members << user
      user.flush
      Permissions::Forums.flush(Discussion, user.id)
      Permissions::Forums.flush(Category, user.id)
      Permissions::Forums.flush(Forum, user.id)
      Permissions::Forums.flush(Reply, user.id)
      admin_log(:members, current_user, :add, "#{user.username} -> #{rank.name}")
    end
    redirect_to [:admin, rank]
  end

  def update
    redirect_if_fail(rank.can_execute?(current_user, :members, :update_role), admin_ranks_url, :action); return if performed?
    mem = Membership.find_by_id(params[:id])
    redirect_if_fail(!mem.nil?, admin_ranks_url, 'Member does not exist!'); return if performed?
    if mem.update(role: params[:membership][:role])
      admin_log(:members, current_user, :update_role, "#{mem.role} -> #{mem.role}")
      flash[:notice] = 'Role updated!'
      redirect_to [:admin, rank]
    else
      flash[:alert] = 'Could not update role!'
      redirect_to [:admin, rank]
    end
  end

  def show
    destroy
  end

  def destroy
    redirect_if_fail(rank.can_execute?(current_user, :members, :remove), admin_ranks_url, :action); return if performed?
    user = User.where(:username => params[:id]).first
    if rank.members.exists?(user.id)
      rank.members.delete(user)
      flash[:notice] = 'Member removed'
      user.flush
      Permissions::Forums.flush(Discussion, user.id)
      Permissions::Forums.flush(Category, user.id)
      Permissions::Forums.flush(Forum, user.id)
      Permissions::Forums.flush(Reply, user.id)
      admin_log(:members, current_user, :remove, "#{user.username} -> #{rank.name}")
    else
      flash[:alert] = 'Member was never a part of this rank'
    end
    redirect_to [:admin, rank]
  end

  private

  def rank
    @rank ||= Rank.find(params[:rank_id])
  end
end
