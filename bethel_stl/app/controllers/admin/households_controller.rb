class Admin::HouseholdsController < Admin::BaseController
  before_action :set_household, only: [:show, :edit, :update, :destroy]

  def index
    @households = Household.includes(:members).order(:name)
  end

  def show
  end

  def new
    @household = Household.new
    @household.members.build
  end

  def create
    @household = Household.new(household_params)

    if @household.members.reject(&:marked_for_destruction?).empty?
      @household.errors.add(:base, 'A household must have at least 1 member')
      render :new, status: :unprocessable_entity
      return
    end

    if @household.save
      redirect_to admin_household_path(@household), notice: 'Household was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @household.assign_attributes(household_params)

    if @household.members.reject(&:marked_for_destruction?).empty?
      @household.errors.add(:base, 'A household must have at least 1 member')
      render :edit, status: :unprocessable_entity
      return
    end

    if @household.save
      redirect_to admin_household_path(@household), notice: 'Household was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @household.destroy
    redirect_to admin_households_path, notice: 'Household was successfully deleted.'
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
