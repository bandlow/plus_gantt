class PgTrackerConfigController < ApplicationController
  
  before_action :check_edit_rights, :load_combo, only: [:edit, :update, :create, :destroy, :new]
  
  def show
	return index
  end
  
  def index
    @is_allowed = User.current.allowed_to_globally?(:config_tracker_timelog)
    @tracker_configs = PgTrackerConfig.all
  end
  
  def new
	@pg_tracker_config = PgTrackerConfig.new
  end
  
  def edit
    @pg_tracker_config = PgTrackerConfig.find(params[:id]) rescue nil 
  end    
  
  def update
	pg_tracker_config = PgTrackerConfig.find(params[:id]) rescue nil 
	respond_to do |format|
	  
		if params[:pg_tracker_config][:project_id]
			pg_tracker_config.project_id = params[:pg_tracker_config][:project_id]
		end
		pg_tracker_config.tracker_id = params[:pg_tracker_config][:tracker_id]
		pg_tracker_config.allow_time_log = params[:pg_tracker_config][:allow_time_log]
	  
	  if pg_tracker_config.save
		format.html { 
			flash[:notice] = 'Tracker Configuration was successfully updated.'
			redirect_to(:action => 'index')
		}
		format.xml  { head :ok }
	  else
		format.html {
		  flash[:error] = "<ul>" + pg_tracker_config.errors.full_messages.map{|o| "<li>" + o + "</li>" }.join("") + "</ul>" 
		  redirect_to(:action => 'edit') }
		format.xml  { render :xml => pg_tracker_config.errors, :status => :unprocessable_entity }
	  end
	end
  end
  
  def create
  
	tracker_config = PgTrackerConfig.new
	
	if params[:pg_tracker_config][:project_id] && !params[:pg_tracker_config][:project_id].blank?
		tracker_config.project_id = params[:pg_tracker_config][:project_id]
	end
	
	tracker_config.tracker_id = params[:pg_tracker_config][:tracker_id]
	tracker_config.allow_time_log = params[:pg_tracker_config][:allow_time_log]
	
	if tracker_config.save
		flash[:notice] = 'Tracker Configuration was successfully saved.'
		redirect_to action: 'index'
	else
		respond_to do |format| 
			format.html {
			  flash[:error] = "<ul>" + tracker_config.errors.full_messages.map{|o| "<li>" + o + "</li>" }.join("") + "</ul>"
			  redirect_to(:action => 'new') }
			format.api  { render_validation_errors(tracker_config) }
		end 
	end
  end
  
  def destroy
    @pg_tracker_config = PgTrackerConfig.find(params[:id]) rescue nil
    @pg_tracker_config.destroy
    flash[:notice] = 'Tracker Configuration was successfully deleted.'
    redirect_to(:action => 'index')
  end

private

	def load_combo
		@allow_options = [[l(:general_text_No), 0], [l(:general_text_Yes), 1]]
		@trackers = Tracker.pluck(:name, :id)
	end

  def check_edit_rights
    is_allowed = User.current.allowed_to_globally?(:config_tracker_timelog)
    if !is_allowed
      flash[:error] = translate 'no_right'
      redirect_to :action => 'index'
    end
  end
end