class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update, :destroy]
  before_action :check_tourney_bans

  def self.permission_definition
  end

  def index
    @tournaments = Tournament.all.order('created_at DESC').paginate(:per_page => 5, :page => params[:page])

    if @tournaments.size == 1
      redirect_to @tournaments[0]
    end
  end

  def show
  end

  def new
    @tournament = Tournament.new

    redirect_if_fail(@tournament.can_execute?(current_user, :create), tournaments_path, :action); return if performed?

    # Edit all on creation
    @editable = Tournament.perm_fields
  end

  def edit
    redirect_if_fail(@tournament.can_execute?(current_user, :update), tournaments_path, :action); return if performed?

    @editable = editable_fields(@tournament)
  end

  def create
    @tournament = Tournament.new(tournament_params)
    redirect_if_fail(@tournament.can_execute?(current_user, :create), tournaments_path, :action); return if performed?

    @tournament.slug = @tournament.name.downcase.gsub(' ', '-')

    if @tournament.save
      redirect_to @tournament, notice: 'Tournament was successfully created.'
    else
      @editable = Tournament.perm_fields
      render :new
    end
  end

  def update
    redirect_if_fail(@tournament.can_execute?(current_user, :update), tournaments_path, :action); return if performed?

    if @tournament.update(tournament_params)
      @tournament.slug = @tournament.name.downcase.gsub(' ', '-')
      @tournament.save
      redirect_to @tournament, notice: 'Tournament was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    redirect_if_fail(@tournament.can_execute?(current_user, :delete), tournaments_path, :action); return if performed?

    @tournament.destroy
    redirect_to tournaments_url, notice: 'Tournament was successfully deleted.'
  end

  private
  def set_tournament
    @tournament = Tournament.find_by_slug(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name, :slug, :about, :open_at, :close_at, :header, :min, :max, :allow_loners)
  end
end
