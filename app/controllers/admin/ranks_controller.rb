class Admin::RanksController < Admin::IndexController

  before_action :get_rank, :only => [:show, :update, :destroy, :copy]
  before_action :perms_check

  def self.permission_definition
  end

  def index
    @ranks = Rank.all.order('priority DESC')
  end

  def new
    @rank = Rank.new
    redirect_if_fail(@rank.can_execute?(current_user, :rank, :create), admin_ranks_url, :action); return if performed?

    # Edit all on creation
    @editable = Rank.perm_fields
  end


  def copy
    @rank = @rank.dup
    redirect_if_fail(@rank.can_execute?(current_user, :rank, :create), admin_ranks_url, :action); return if performed?

    # Edit all on creation
    @editable = Rank.perm_fields

    render :new
  end

  def show
    redirect_if_fail(@rank.can_execute?(current_user, :rank, :update), admin_ranks_url, :action); return if performed?

    @editable = editable_fields(@rank)

    # Global Scopes
    @perms = Avicus::Application.config.web_perms
    # Ranks
    @ranks = Rank.all.order('priority DESC').to_a
    @ranks.unshift(Rank.new(:name => 'All Ranks', :id => 'all'))
    @rank_gen = find_perm_gen('rank')
    # Forums
    @forums = Forum.all
    @global_cat = Category.new(name: 'All Forums', id: 'all')
    @forum_gen = find_perm_gen(:categories)

    @api_gen = find_perm_gen(:api)

    # Fix for after creation
    if @rank.mc_perms.nil? || @rank.mc_perms == "--- []\n"
      @rank.mc_perms = ''
    end

    if @rank.ts_perms.nil? || @rank.ts_perms == "--- []\n"
      @rank.ts_perms = ''
    end

    # Server category permissions
    @special_perms = {}
    @special_perms = JSON.parse(@rank.special_perms) unless @rank.special_perms.nil?
  end

  def create
    @rank = Rank.new(allowed_params)
    redirect_if_fail(@rank.can_execute?(current_user, :rank, :create), admin_ranks_url, :action); return if performed?

    if @rank.save
      flash[:notice] = 'Rank created'
      redirect_to [:admin, @rank]
      admin_log(:ranks, current_user, :create, @rank.name)
    else
      flash[:alert] = '@rank.errors'
      @editable = Rank.perm_fields

      render :new
    end
  end

  def update
    redirect_if_fail(@rank.can_execute?(current_user, :rank, :update), admin_rank_path(@rank), :action); return if performed?

    @rank.mc_perms = params[:mc_perms].gsub("\r", '').split("\n") unless params[:mc_perms].nil?
    @rank.ts_perms = params[:ts_perms].gsub("\r", '').split("\n") unless params[:ts_perms].nil?

    unless params[:rank][:special].nil? || params[:rank][:special] == {}
      fixed = {}
      params[:rank][:special].each do |key, val|
        fixed[key] = val.gsub("\r", '').split("\n")
      end
      @rank.special_perms = fixed.to_json
    end

    @rank.web_perms = params[:rank][:web_perms] unless params[:rank][:web_perms].nil? || params[:rank][:web_perms] == {}

    if @rank.update_attributes(allowed_params)
      flash[:notice] = 'Rank successfully updated.'
      admin_log(:ranks, current_user, :update, @rank.name)
    else
      flash[:error] = 'Rank failed to update.'
    end

    redirect_to admin_rank_path(@rank)
  end

  def destroy
    redirect_if_fail(@rank.can_execute?(current_user, :rank, :destroy), admin_rank_path(@rank), :action); return if performed?

    @rank.destroy
    flash[:notice] = 'Rank removed'
    admin_log(:ranks, current_user, :destroy, @rank.name)
    redirect_to admin_ranks_path
  end

  private

  def get_rank
    @rank = Rank.find(params[:id] || params[:rank_id])
  end

  def find_perm_gen(ident)
    Avicus::Application.config.web_perms.each do |gen|
      return gen if gen.parent_group.ident == ident
    end
    return nil
  end

  def perms_check
    redirect_if_fail(current_user.has_permission?('admin:index_controllers', :view, :ranks, true), '/', :page)
  end

  def allowed_params
    params[:rank].permit(:name, :priority, :is_staff, :html_color, :badge_color, :badge_text_color, :mc_prefix, :mc_suffix, :mc_perms, :ts_perms, :inheritance_id)
  end

end
