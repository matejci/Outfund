# frozen_string_literal: true

class UndergroundSystem
  Trip = Struct.new(:id, :event, :station, :time)

  def initialize
    @trips = []
    @num_of_trips = 0
  end

  def check_in(id, station_name, time)
    raise 'Customer already checked in' if already_checked_in?(id)

    @trips << Trip.new(id, :in, station_name, time)
  end

  def check_out(id, station_name, time)
    @trips << Trip.new(id, :out, station_name, time)
  end

  def get_average_time(start_station, end_station)
    trip_time = 0
    trips_by_customer = @trips.group_by(&:id)

    trips_by_customer.each do |_customer, c_trips|
      checkins_checkouts = parse_trips(c_trips, start_station, end_station)

      next if checkins_checkouts[:checkouts].nil? # In case customer only checked-in once, but hasn't checked-out yet.

      trip_time += process_customer_trips(checkins_checkouts)
    end

    (trip_time / @num_of_trips.to_f).round(2)
  end

  private

  def process_customer_trips(checkins_checkouts)
    customer_trip_time = 0
    checkins = checkins_checkouts[:checkins]
    checkouts = checkins_checkouts[:checkouts]

    checkins.each_with_index do |checkin, ind|
      break if checkouts[ind].nil? # If there are unpaired number of check ins and checkouts, ignore unpaired events.

      @num_of_trips += 1
      customer_trip_time += checkouts[ind].time - checkin.time
    end

    customer_trip_time
  end

  def parse_trips(customer_trips, start_station, end_station)
    relevant_trips = customer_trips.select do |trip|
      (trip.station == start_station && trip.event == :in) || (trip.station == end_station && trip.event == :out)
    end

    grouped_trips = relevant_trips.group_by(&:event)

    {
      checkins: grouped_trips[:in]&.sort_by(&:time),
      checkouts: grouped_trips[:out]&.sort_by(&:time)
    }
  end

  def already_checked_in?(id)
    customer_trips = @trips.select { |trip| trip.id == id }
    return false unless customer_trips

    customer_events = customer_trips.group_by(&:event)

    customer_events[:in]&.size.to_i > customer_events[:out]&.size.to_i
  end
end
