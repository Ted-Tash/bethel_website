class Admin::HouseholdsController < Admin::BaseController
  before_action :set_household, only: [:show, :edit, :update, :destroy]

  def index
    @households = Household.includes(:members).order(:name)
  end

  def show
    if params[:slideout]
      render :show_slideout, layout: false
    end
  end

  def new
    @household = Household.new
    @household.members.build

    if params[:slideout]
      render :new_slideout, layout: false
    end
  end

  def create
    @household = Household.new(household_params)

    if @household.members.reject(&:marked_for_destruction?).empty?
      @household.errors.add(:base, 'A household must have at least 1 member')
      if params[:slideout]
        render :new_slideout, layout: false, status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
      return
    end

    if @household.save
      if params[:slideout]
        render :create_slideout, formats: [:turbo_stream], layout: false
      else
        redirect_to admin_household_path(@household), notice: 'Household was successfully created.'
      end
    elsif params[:slideout]
      render :new_slideout, layout: false, status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if params[:slideout]
      render :edit_slideout, layout: false
    end
  end

  def update
    @household.assign_attributes(household_params)

    if @household.members.reject(&:marked_for_destruction?).empty?
      @household.errors.add(:base, 'A household must have at least 1 member')
      if params[:slideout]
        render :edit_slideout, layout: false, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
      return
    end

    if @household.save
      if params[:slideout]
        render :update_slideout, formats: [:turbo_stream], layout: false
      else
        redirect_to admin_household_path(@household), notice: 'Household was successfully updated.'
      end
    elsif params[:slideout]
      render :edit_slideout, layout: false, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @household.destroy

    respond_to do |format|
      format.turbo_stream { render :destroy_slideout, formats: [:turbo_stream], layout: false }
      format.html { redirect_to admin_households_path, notice: 'Household was successfully deleted.' }
    end
  end

  private

  def set_household
    @household = Household.find(params[:id])
  end

  def household_params
    params.require(:household).permit(
      :name, :street, :city, :state, :zip,
      members_attributes: [:id, :first_name, :last_name, :email, :phone, :_destroy]
    )
  end
end
