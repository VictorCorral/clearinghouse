module ApplicationHelper
  def formatted_address_and_city(location)
    unless location.blank?
      raw location.address_and_city('<br/>')
    end
  end
  
  def formatted_address_city_and_zip(location)
    unless location.blank?
      raw location.address_city_and_zip('<br/>')
    end
  end
  
  def display_appointment_time(trip_ticket)
    if !trip_ticket.appointment_time.blank?
      trip_ticket.appointment_time.to_s(:time)
    elsif trip_ticket.scheduling_priority == "pickup" && !trip_ticket.requested_pickup_time.blank?
      trip_ticket.requested_pickup_time.to_s(:time)
    elsif !trip_ticket.requested_drop_off_time.blank?
      trip_ticket.requested_drop_off_time.to_s(:time)
    else
      ""
    end
  end
end