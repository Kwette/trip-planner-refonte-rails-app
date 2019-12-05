# require 'pry-byebug'

class StepsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  DUR_ACTIVITY_PER_DAY = 2 * 60

  def index
    @steps = Step.all
  end

  def new
    @trip = Trip.find(params[:trip_id])
    @step = Step.new
    # 1.step - find all activities between long lat arrival and departure point with radius
    @activities = activities_in_zone(@trip)
    # 2.step - fix one activity in arrival and departure city must see not user preferences
    arrival_city = @trip.arrival_city
    departure_city = @trip.departure_city
    @fixed_activities = []
    @fixed_activities_ids = []
    # slecting all activities in arrival city and sorting by ranking
    arrival_city_activities = @activities.select do |activity|
      activity.city == arrival_city
    end
    arrival_city_activities = arrival_city_activities.sort_by!{|act| act.ranking_interest }
    # slecting all activities in departure city and sorting by ranking
    departure_city_activities = @activities.select do |activity|
      activity.city == departure_city
    end
    departure_city_activities = departure_city_activities.sort_by!{|act| act.ranking_interest }
    # fix first activity in arrival city and in departure city
    @fixed_activities << arrival_city_activities.first
    @fixed_activities << departure_city_activities.first
    @fixed_activities_ids << arrival_city_activities.first.id
    @fixed_activities_ids << departure_city_activities.first.id
    # deleting two fixed activities from activities
    @activities = @activities.reject do |activity|
      activity == arrival_city_activities.first
    end
    @activities = @activities.reject do |activity|
      activity == departure_city_activities.first
    end
    # 3.step -  calculate total time of user for activities
    @user_time_activities_total = ((@trip.end_date - @trip.start_date) / 86400) * DUR_ACTIVITY_PER_DAY  # -> nb days * activity duration per day (en heures)
    # 4.step - total user time minus time of fixed activitites
    total_fixed_trip_duration = total_duration(@fixed_activities)
    @user_time_activities_total -= total_fixed_trip_duration
    # 5.step - define real time of filtered activities by category, by ranking
    @list_acti_all_real = []
    @time_activities_real = 0
    # 6. step define arrays of real and double time activities
    @list_acti_culture_real = []
    @list_acti_sport_real = []
    @list_acti_visit_real = []
    @list_acti_beach_real = []
    @list_acti_culture_double = []
    @list_acti_sport_double = []
    @list_acti_visit_double = []
    @list_acti_beach_double = []

    # loop steps 7-12 to fill all user time for activities => 6h=360min of flexibility
    #until (@user_time_activities_total - 360) >= @time_activities_real || @activities.size == @list_acti_all_real.size do
      # 7.step - calculate time per categorie for user preferences - time for fixed activities
      # time for activities by type
      @ratio_type_activities = ratio_duration(@trip, @user_time_activities_total)
      # double time for activities for choices
      @ratio_type_activities_double = ratio_duration_double(@trip, @user_time_activities_total)
      # 8.step - filter activities by category, by ranking, by time
      # culture
      @list_acti_culture_r = filter_activities_by_time(@activities, @ratio_type_activities, "culture")
      @list_acti_culture_d = filter_activities_by_time(@activities, @ratio_type_activities_double, "culture")
      # sport
      @list_acti_sport_r = filter_activities_by_time(@activities, @ratio_type_activities, "sport")
      @list_acti_sport_d = filter_activities_by_time(@activities, @ratio_type_activities_double, "sport")
      # visit
      @list_acti_visit_r = filter_activities_by_time(@activities, @ratio_type_activities, "visit")
      @list_acti_visit_d = filter_activities_by_time(@activities, @ratio_type_activities_double, "visit")
      # beach
      @list_acti_beach_r = filter_activities_by_time(@activities, @ratio_type_activities, "beach")
      @list_acti_beach_d = filter_activities_by_time(@activities, @ratio_type_activities_double, "beach")
      # 9.step - push real and double elements to their array
      @list_acti_culture_real = push_elements_to_all_array(@list_acti_culture_r, @list_acti_culture_real)
      @list_acti_sport_real = push_elements_to_all_array(@list_acti_sport_r, @list_acti_sport_real)
      @list_acti_visit_real = push_elements_to_all_array(@list_acti_visit_r, @list_acti_visit_real)
      @list_acti_beach_real = push_elements_to_all_array(@list_acti_beach_r, @list_acti_beach_real)
      @list_acti_culture_double = push_elements_to_all_array(@list_acti_culture_d, @list_acti_culture_double)
      @list_acti_sport_double = push_elements_to_all_array(@list_acti_sport_d, @list_acti_sport_double)
      @list_acti_visit_double = push_elements_to_all_array(@list_acti_visit_d, @list_acti_visit_double)
      @list_acti_beach_double = push_elements_to_all_array(@list_acti_beach_d, @list_acti_beach_double)
      # 10.step - creating array of real activities
      @list_acti_all_real = push_elements_to_all_array(@list_acti_culture_real, @list_acti_all_real)
      @list_acti_all_real = push_elements_to_all_array(@list_acti_sport_real, @list_acti_all_real)
      @list_acti_all_real = push_elements_to_all_array(@list_acti_visit_real, @list_acti_all_real)
      @list_acti_all_real = push_elements_to_all_array(@list_acti_beach_real, @list_acti_all_real)
      # 11.step - recalculate real time of filtered activities by category, by ranking
      @time_activities_real = total_duration(@list_acti_all_real)
      # 12. step - recalculate total user time for activities
      @user_time_activities_total -= @time_activities_real
    #end

    # 13.step - fix activities by categorie
    @list_acti_culture_fixed = activities_fixed(@list_acti_culture_real, @list_acti_culture_double)
    @list_acti_sport_fixed = activities_fixed(@list_acti_sport_real, @list_acti_sport_double)
    @list_acti_visit_fixed = activities_fixed(@list_acti_visit_real, @list_acti_visit_double)
    @list_acti_beach_fixed = activities_fixed(@list_acti_beach_real, @list_acti_beach_double)
    # 14.step - push fixed activities to all fixed activities ids
    @fixed_activities_ids = push_elements_to_all_array(@list_acti_culture_fixed, @fixed_activities_ids)
    @fixed_activities_ids = push_elements_to_all_array(@list_acti_sport_fixed, @fixed_activities_ids)
    @fixed_activities_ids = push_elements_to_all_array(@list_acti_visit_fixed, @fixed_activities_ids)
    @fixed_activities_ids = push_elements_to_all_array(@list_acti_beach_fixed, @fixed_activities_ids)
    # 15.step - activities to choose for user
    @list_acti_culture_choose = activities_to_choose(@list_acti_culture_real, @list_acti_culture_double)
    @list_acti_sport_choose = activities_to_choose(@list_acti_sport_real, @list_acti_sport_double)
    @list_acti_visit_choose = activities_to_choose(@list_acti_visit_real, @list_acti_visit_double)
    @list_acti_beach_choose = activities_to_choose(@list_acti_beach_real, @list_acti_beach_double)

    # help dev nb of activities
    @activities_culture = @activities.select do |activity|
      activity.activity_types == "culture"
    end

    @activities_sport = @activities.select do |activity|
      activity.activity_types == "sport"
    end

    @activities_visit = @activities.select do |activity|
      activity.activity_types == "visit"
    end

    @activities_beach = @activities.select do |activity|
      activity.activity_types == "beach"
    end
  end

  # method to push activities by category to array
  def push_elements_to_all_array(list, list_all)
    if list.size == 1
      list_all << list.first
    elsif list.size > 1
      list.each do |activity|
        list_all << activity
      end
    end
    return list_all
  end

  # method to fix activities by category
  def activities_fixed(list_real, list_double)
    @list_acti_fixed = []
    if list_real.size.zero?
      # activities with same duration that real and plus minus 30 min
      @list_acti_fixed = []
    elsif list_real.size == 1
      # activities to choose when 2 activities
      @list_acti_fixed << list_real.first.id
    elsif list_real.size == list_double.size
      list_real.each do |activity|
        @list_acti_fixed << activity.id
      end
    elsif list_real.size == 2
      @list_acti_fixed = []
    else
      # activities to choose when plus 2 activities
      list_real[0..list_real.size - 3].each do |activity|
        @list_acti_fixed << activity.id
      end
    end
    return @list_acti_fixed
  end

  # method to select activities to propose to client
  def activities_to_choose(list_real, list_double)
    @list_acti_choose = []
    if list_real.size <= 1
      # activities with same duration that real and plus minus 30 min
      @list_acti_choose = []
    elsif list_real.size == list_double.size
      @list_acti_choose = []
    elsif list_real.size == 2
      # activities to choose when 2 activities
      @list_acti_choose = list_double.first(4)
    else
      # activities to choose when plus 2 activities
      list_double[(list_real.size - 2)..(list_real.size + 1)].each do |activity|
        @list_acti_choose << activity
      end
    end
    return @list_acti_choose
  end

  def filter_activities_by_time(activities, ratio_type_activities, criteria)
    order_list = order_by_ranking(activities, criteria)
    total_list = total_duration(order_list)
    list_acti = []
    if total_list < ratio_type_activities[criteria]
      list_acti << order_list
      list_acti.flatten!
      return list_acti
    else
      order_list.each do |acti|
        return list_acti if (total_duration(list_acti) + acti.duration) > ratio_type_activities[criteria]

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

  def ratio_duration(trip, total_trip_duration)
    # total criteria user choice
    total_criteria_choice = trip.criteria["beach"].to_i + trip.criteria["culture"].to_i + trip.criteria["visit"].to_i + trip.criteria["sport"].to_i
    # calculate choices to 100%
    beach_choice = trip.criteria["beach"].to_i * 100 / total_criteria_choice
    culture_choice = trip.criteria["culture"].to_i * 100 / total_criteria_choice
    sport_choice = trip.criteria["sport"].to_i * 100 / total_criteria_choice
    visit_choice = trip.criteria["visit"].to_i * 100 / total_criteria_choice
    # calculates ratio of duration of each criteria vs total duration of trip activity
    beach_ratio = (total_trip_duration * beach_choice) / 100
    visit_ratio = (total_trip_duration * visit_choice) / 100
    culture_ratio = (total_trip_duration * culture_choice) / 100
    sport_ratio = (total_trip_duration * sport_choice) / 100
    ratio_duration = { "beach" => beach_ratio, "visit" => visit_ratio, "culture" => culture_ratio, "sport" => sport_ratio}
    return ratio_duration
  end

  def ratio_duration_double(trip, total_trip_duration)
    # total criteria user choice
    total_criteria_choice = trip.criteria["beach"].to_i + trip.criteria["culture"].to_i + trip.criteria["visit"].to_i + trip.criteria["sport"].to_i
    # calculate choices to 100%
    beach_choice = trip.criteria["beach"].to_i * 100 / total_criteria_choice
    culture_choice = trip.criteria["culture"].to_i * 100 / total_criteria_choice
    sport_choice = trip.criteria["sport"].to_i * 100 / total_criteria_choice
    visit_choice = trip.criteria["visit"].to_i * 100 / total_criteria_choice
    # calculates double ratio of duration of each criteria vs total duration of trip activity
    total_trip_duration_double = total_trip_duration * 2
    beach_ratio = (total_trip_duration_double * beach_choice) / 100
    visit_ratio = (total_trip_duration_double * visit_choice) / 100
    culture_ratio = (total_trip_duration_double * culture_choice) / 100
    sport_ratio = (total_trip_duration_double * sport_choice) / 100
    ratio_duration_double = { "beach" => beach_ratio, "visit" => visit_ratio, "culture" => culture_ratio, "sport" => sport_ratio}
    return ratio_duration_double
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

  def create
    # find trip
    @trip = Trip.find(params[:trip_id])
    unless @trip.steps.empty?
      @trip.steps.destroy_all
    end
    activities_choosen = []
    # clean params activities ids from ''
    if params[:activities_ids].present?
      activities_choosen = params[:activities_ids].reject do |activity_id|
        activity_id == ''
      end
    end

    # array of fixed activities in string
    if params[:activities_fixed_ids].present?
      activities_fixed = params[:activities_fixed_ids].join.gsub("[", "").gsub("]", "").split(", ")
      # pushing fixed activities to choosen
      activities_fixed.each do |activity_id|
        activities_choosen << activity_id
      end
    end

    # creating hash key: city_id value: array of activities
    step_hash = {}
    activities_choosen.each do |activity_id|
      activity = Activity.find(activity_id)
      if step_hash.key?(activity.city.id)
        step_hash[activity.city.id] << activity.id
      else
        step_hash[activity.city.id] = [activity.id]
      end
    end

    step_hash.each do |key, value|
      # creating steps for each key=city_id
      step = Step.new
      step.city = City.find(key)
      step.trip = @trip
      # step.order = 5
      # step.time_next_step = 5
      # step.distance_next_step = 5
      step.save
      # creating step_activities for each value=array of activities
      step_duration = 0
      value.each do |activity_id|
        step_activity = StepActivity.new
        step_activity.step = step
        step_activity.activity = Activity.find(activity_id)
        step_duration += step_activity.activity.duration
        step_activity.save
      end
      step.duration = (step_duration / DUR_ACTIVITY_PER_DAY).round()
      step.save
    end
    redirect_to mistery_trip_path(@trip)
  end

  def show

    @step = Step.find(params[:id])
  end

end
