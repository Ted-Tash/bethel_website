class Admin::ContactGroupsController < Admin::BaseController
  before_action :set_contact_group, only: [:edit, :update, :destroy]

  def index
    @contact_groups = ContactGroup.all.order(:name)
  end

  def new
    @contact_group = ContactGroup.new
    @members = members_grouped_by_household
  end

  def create
    @contact_group = ContactGroup.new(contact_group_params)

    if @contact_group.save
      redirect_to admin_contact_groups_path, notice: "Contact group was successfully created."
    else
      @members = members_grouped_by_household
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @members = members_grouped_by_household
  end

  def update
    if @contact_group.update(contact_group_params)
      redirect_to admin_contact_groups_path, notice: "Contact group was successfully updated."
    else
      @members = members_grouped_by_household
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact_group.destroy
    redirect_to admin_contact_groups_path, notice: "Contact group was successfully deleted."
  end

  private

  def set_contact_group
    @contact_group = ContactGroup.find(params[:id])
  end

  def contact_group_params
    params.require(:contact_group).permit(:name, member_ids: [])
  end

  def members_grouped_by_household
    Household.includes(:members).order(:name).map do |household|
      [household, household.members.order(:first_name)]
    end
  end
end
