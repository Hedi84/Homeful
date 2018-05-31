class RecipientsController < ApplicationController
  before_action :set_recipient, except: [:new, :index, :create]

  def index
     if params[:search].present? && params[:location].present?
      search_recipients = Recipient.search_everything(params[:search])
      recipients = Recipient.locations.first.near(params[:location], 20)
      location_recipients = []
      recipients.each do |u|
        u.recipients.each do |d|
          location_recipients << d
        end
      end
      @recipients = search_recipients & location_recipients

    elsif params[:location].present?
      locations = Location.near(params[:location], 20)
      location_recipients = []
      locations.each do |u|
        u.recipient.each do |d|
          location_recipients << d
        end
      end
      @recipients = location_recipients

    elsif params[:search].present?
      @recipients = Recipient.search_everything(params[:search])
    else
      @recipients = Recipient.all
    end

    # locations
    @recipients = Recipient.all.select {|recipient| recipient.locations.count > 0}
    @markers = []
    @recipients.each do |recipient|
     recipient.locations.each do |location|
      if location.primary == true
        hash = {
          lat: location.latitude,
          lng: location.longitude,
          infoWindow: { content: render_to_string(partial: "shared/info_window", locals: { recipient: recipient }) }
        }
        @markers << hash
      end
    end
  end
end

def new
  @recipient = Recipient.new
  @location = Location.new
end

def create
  @recipient = Recipient.new(recipient_params)
  @recipient.user = current_user
  @location = Location.new(address: params[:recipient][:location][:address])
  @location.primary = true
  @location.save
  @recipient.locations << @location
  if @recipient.save
      # authorize @recipient
      redirect_to recipient_path(@recipient)
    else
      render "new"
    end
  end

  def edit
    # authorize @recipient
  end

  def update
    # authorize @recipient
    @recipient.update(recipient_params)
    if @recipient.save
      redirect_to recipient_path
    else
      render "edit"
    end
  end

  def destroy
    # authorize @recipient
    @recipient.delete
  end

  def show
    @contribution = Contribution.new

    @markers = []
    @recipient.locations.each do |location|
      hash = {
        lat: location.latitude,
        lng: location.longitude
      }
      if location.primary == true
      hash[:type] = "primary"
     end
        @markers << hash
    end

  end

  private

  def set_recipient
    @recipient = Recipient.find(params[:id])
  end

  def recipient_params
    params.require(:recipient).permit(:first_name, :last_name, :gender, :date_of_birth, :bio, :phone_number, :photo)
  end

  # def location_params
  #   params.require(:recipient).permit(:locations_attributes)
  # end

end
