require 'json'
require 'open-uri'

class TripsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :mistery, :show, :create, :change_mistery]
  def index
    @trips = Trip.where(user: current_user)
  end

  def new
    @trip = Trip.new
    @step = Step.new
  end

  def create
    @trip = Trip.new(trip_params)
    redirect_to new_trip_step_path(@trip) if @trip.save!
  end

  def show
    @trip = Trip.find(params[:id])
    @list_acti_map = []
    @trip.steps.each do |step|
      @list_acti_map << step.activities
    end
    response = ordonated_steps(@trip)
    steps_to_map(response, false)
  end

  def ordonated_steps(trip)
    order_steps = []
    trip.steps.each do |step|
      if step.city_id == trip.departure_city_id
        order_steps.prepend(step)
      elsif step.city_id == trip.arrival_city_id
        next
      else
        order_steps << step
      end
    end
    #first and last city need to be at begining and end for API optimize call
    order_steps << trip.steps.find{|step| step.city_id == trip.arrival_city_id }
    steps_coord = ""
    order_steps.each do |step|
      steps_coord += step.city.longitude.to_s + ',' + step.city.latitude.to_s + ';'
    end
    steps_call = steps_coord.delete_suffix(";")
    url = "https://api.mapbox.com/optimized-trips/v1/mapbox/driving/#{steps_call}?source=first&destination=last&steps=true&access_token=#{ENV['MAPBOX_API_KEY']}"
    response_serialized = open(url).read
    return response = JSON.parse(response_serialized)
  end

  def steps_to_map(response, details)
    steps = response['waypoints'].sort_by! { |waypoint| waypoint['waypoint_index'] }
    i = -1
    @markers = steps.map do |step|
      leg = response["trips"][0]["legs"][i]
      this_step = @trip.steps.find{ |st| step['location'][0].round(2) == st.city.longitude.round(2) }
      this_step.distance_next_step = (response["trips"][0]["legs"][i]['distance']/1_000).round(2)
      this_step.save
      i += 1
      # define the order of the trip steps
      step_to_order = @trip.steps.where(id: this_step.id).first
      step_to_order.order = i
      step_to_order.save!
      {
        infoWindow: render_to_string(partial: "infowindow", locals: { step: this_step, api_step: leg, trip: Trip.find(params[:id]), infos: details }),
        lat: step['location'][1],
        lng: step['location'][0]
      }
    end
  end

  def activities_to_map(activities)
    # .select {|item| !(item[:lat].nil? || item[:long].nil?)}.
    @markers = activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude
      }
    end
  end

  def filter_activities_by_time(criteria)
    order_list = order_by_ranking(@activities, criteria)
    total_list = total_duration(order_list)
    list_acti = []
    if total_list < @ratio_type_activities[criteria]
      list_acti << order_list
      list_acti.flatten!
      return list_acti
    else
      order_list.each do |acti|
        return list_acti if (total_duration(list_acti) + acti.duration) > @ratio_type_activities[criteria]
        list_acti << acti
      end
    end
  end

  def activities_in_zone(trip)
    long_max = [trip.arrival_city.longitude, trip.departure_city.longitude].max
    long_min = [trip.arrival_city.longitude, trip.departure_city.longitude].min
    lat_max = [trip.arrival_city.latitude, trip.departure_city.latitude].max
    lat_min = [trip.arrival_city.latitude, trip.departure_city.latitude].min
    activities = Activity.where('longitude BETWEEN ? AND ?', long_min - 0.5, long_max + 0.5).where('latitude BETWEEN ? AND ?', lat_min - 0.5, lat_max + 0.5)
    return activities
  end

  def ratio_duration(trip)
    # calculates ratio of duration of each criteria vs total duration of trip activity
    total_trip_duration = ((trip.end_date - trip.start_date) / 86_400) * 8 * 60 # -> nb days * 8h * 60min
    criteria_sum = trip.criteria["beach"].to_f + trip.criteria["visit"].to_f + trip.criteria["culture"].to_f + trip.criteria["sport"].to_f
    beach_ratio = (total_trip_duration * trip.criteria["beach"].to_f) / criteria_sum
    visit_ratio = (total_trip_duration * trip.criteria["visit"].to_f) / criteria_sum
    culture_ratio = (total_trip_duration * trip.criteria["culture"].to_f) / criteria_sum
    sport_ratio = (total_trip_duration * trip.criteria["sport"].to_f) / criteria_sum

    ratio_duration = { "beach" => beach_ratio, "visit" => visit_ratio, "culture" => culture_ratio, "sport" => sport_ratio }
    @total_trip_duration = total_trip_duration
    return ratio_duration
  end

  def order_by_ranking(array, type)
    result = array.select do |array_act|
      array_act.activity_types == type
    end
    result.sort_by!{|act| act.ranking_interest }
    return result
  end

  def total_duration(array)
    sum = 0
    array.each do |act|
      sum += act.duration
    end
    return sum
  end

  def edit
    @trip = Trip.find(params[:id])
  end

  def preferences
    @trip = Trip.find(params[:id])
    @trip.steps.each do |step|
      step.step_activities.each do |step_act|
        if step_act.activity.activity_types == "party"
          StepActivity.destroy(step_act.id)
        end
      end
    end
    @trip.criteria['party'] = params['trip']['criteria']['party']
    count = 0
    @trip.steps.each do |step|
      count += step.duration
    end
    trip_cities = []
    nb_party = count * (@trip.criteria['party'].to_i)/100.round
    good_parties = order_by_ranking(Activity.all, "party")
    @trip.steps.each do |step|
      trip_cities << step.city
    end
    good_parties_good_city = good_parties.reject{|party| !trip_cities.include?party.city }
    good_parties_good_city.first(nb_party).each do |party|
      step_party = @trip.steps.find_by(city: party.city)
      StepActivity.create!(step: step_party, activity: party)

    end
    if @trip.save
      redirect_to details_trip_path(@trip)
    else
      render :edit
    end
  end

  def order_by_ranking(array, type)
  result = array.select do |array_act|
    array_act.activity_types == type
  end
  result.sort_by!{|act| act.ranking_interest }
  return result
  end


  def update
    @trip = Trip.find(params[:id])
    if @trip.update(trip_params)
      redirect_to new_trip_step_path(@trip)
    else
      render :edit
    end
  end

  def details
    @trip = Trip.find(params[:id])
    @step = Step.new
    list = activities(@trip)
    response = ordonated_steps(@trip)
    steps_to_map(response, true)
  end

  def activities(trip)
    trip_activities = []
    trip.steps.each do |step|
      trip_activities << step.activities
    end
    trip_activities.flatten!
    return trip_activities
  end

  def save
    @trip = Trip.find(params[:id])
    @trip.user = current_user if current_user.present?
    redirect_to(trips_path, alert: 'Trip was successfully saved') if @trip.save!
  end

  def mistery
    # display of mistery choice
    @trip = Trip.find(params[:id])
  end

  def change_mistery
    # 1 step -  update percentage of mistery in trip
    @trip = Trip.find(params[:id])
     @trip.update(trip_params)
     # 2 step -  put all step acti at false
     @trip.steps.each do |step|
      step.step_activities.each do |step_activity|
        step_activity.mistery = false
        step_activity.save
      end
     end
      # 2 step -  number of all activities in the trip
      @nb_all_activities_trip = 0
      @trip.steps.each do |step|
        @nb_all_activities_trip += step.step_activities.count
      end
      # 3 step -  total number of activities to hide
      @nb_all_activities_trip_hide = @nb_all_activities_trip * @trip.percentage_of_mistery / 100
      # 4 step - hide activities in steps

      @trip.steps.each do |step|
        #make visible if step has only one activity
        if step.step_activities.count == 1 && @trip.percentage_of_mistery != 100
          step.step_activities.first.mistery = false
        else
          # create a list of step activities
        activities_in_step_ids = []
        step.step_activities.each do |step_activity|
          activities_in_step_ids << step_activity.id
        end
        # number of activities in step
        nb_all_activities_step = step.step_activities.count
        # percentage of activities in step from total activities of trip
        percentage_activities_in_step = nb_all_activities_step * 100 / @nb_all_activities_trip
        # nb of activities to hide in step
        nb_all_activities_step_hide = (@nb_all_activities_trip_hide * percentage_activities_in_step / 100.to_f).ceil

        # nb of activities to hide times
        nb_all_activities_step_hide.times do
          # choose one activity from step random
          activity_sample = activities_in_step_ids.sample
          # find activity in step activities
          step_activity = StepActivity.find(activity_sample)
          # mistery is true
          step_activity.mistery = true
          step_activity.save
          # delete this activity from the list of all activities in step
          activities_in_step_ids.delete(activity_sample)
        end
      end
        end

      if user_signed_in?
        redirect_to details_trip_path(@trip)
      else
        redirect_to trip_path(@trip)
      end

  end

  private

  def trip_params
    params.require(:trip).permit(:departure_city_id, :arrival_city_id, :start_date, :end_date, :percentage_of_mistery, criteria: {})
  end
end
