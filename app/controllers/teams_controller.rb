class TeamsController < ApplicationController
  def edit
    @team = Team.find(params[:id])
    if !@team
        flash[:error] = "Cannot find Team with id #{params[:id]}!"
        redirect_to teams_path
    end
  end

  def update
    @team = Team.find(params[:id])
    if @team
      if @team.update_attributes(team_params)
        flash[:success] = "Team Info updated"
        redirect_to @team
      else
        render 'edit'
      end
    else
        flash[:error] = "Cannot find Team with id #{params[:id]}!"
        redirect_to teams_path
    end
  end
  def show
    @team = Team.find(params[:id])
    if !@team
        flash[:error] = "Cannot find Team with id #{params[:id]}!"
        redirect_to teams_path
    end
  end
  def index
    @teams = Team.where(nfl: true).paginate(page: params[:page], per_page: 11).order('name ASC')
  end
  
  private

    def team_params
      params.require(:team).permit(:name, :nfl, 
                                   :imagePath)
    end

    def authenticate
      deny_access unless signed_in?
    end

    # Before filters
    def admin_user
      redirect_to current_user, notice: "Only an Admin User can access that page!" unless current_user.admin?
    end
end