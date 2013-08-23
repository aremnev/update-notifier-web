class ResourcesController < ApplicationController
  include ResourcesHelper
  include TagsHelper

  def create
    # Create resource
    id = session[:user_id]
    tags = DatabaseHelper.tags(id)
    resource_info = params[:resource]
    resource_info[:tags] = add_new_tags(resource_info[:tags], id)
    resource_info[:schedule_code] = ResourcesHelper.schedule_codes.index(resource_info[:schedule_code])
    resource = Resource.new(resource_info)
    resource.user_id = id

    if resource.valid?
      DatabaseHelper.add_resource(resource)
    else
      @errors_array = resource.errors.full_messages
    end
    redirect_to :back, flash: {errors: @errors_array}

  end

  def index
    @schedule_codes = ResourcesHelper.schedule_codes
    # 'Index' page - list of all resources and options
    @errors_array = flash[:errors]
    user = session[:user]
    session[:user_id] = @id = user[:id]
    @name = user[:name]
    @tags = DatabaseHelper.tags(@id)
    @selected_tags = session[:selected_tags] || []
    @selected_tags.each do |item|
      keys = @tags.keys
      @selected_tags.delete(item) if !(keys.include? item.to_i)
    end
    tag_str = tags_to_url(@selected_tags.dup)
    @resources = DatabaseHelper.resources(@id, (tag_str.blank? ? nil : {tags: tag_str}))
  end

  def show
    resource_id = params[:id]
    id = session[:user_id]
    @resource = DatabaseHelper.get_resource(id, resource_id)
    @tag_string = get_tags_string(@resource, DatabaseHelper.tags(id))
  end

  def edit
    resource_id = params[:id]
    id = session[:user_id]
    @resource = DatabaseHelper.get_resource(id, resource_id)
    @tag_string = get_tags_string(@resource, DatabaseHelper.tags(id))
    @schedule_codes = ResourcesHelper.schedule_codes
    @schedule_code = schedule_code_to_s(@resource.schedule_code)
  end

  def update
    id = session[:user_id]
    tags = DatabaseHelper.tags(id)
    resource_info = params[:resource]
    resource_info[:tags] = add_new_tags(resource_info[:tags], id)
    resource_info[:id] = params[:id]
    resource_info[:user_id] = id
    resource_info[:schedule_code] = ResourcesHelper.schedule_codes.index(resource_info[:schedule_code])
    resource = Resource.new(resource_info)
    if resource.valid?
      DatabaseHelper.edit_resource(resource)
    else
      @errors_array = resource.errors.full_messages
    end
    redirect_to action: :index
  end

  def destroy
    result = DatabaseHelper.delete_resource(session[:user_id], params[:id])
    redirect_to action: :index
  end

  def filtered_by
    # TODO make it normal

    if params[:id].to_i > 0
      selected_tag = params[:id].to_i
    else
      tags = DatabaseHelper.tags(session[:user_id])
      key = tags.keys.select do |key|
        tags[key] == params[:tag]
      end
      selected_tag = key.first
    end

    selected_tags = session[:selected_tags]
    if selected_tags.nil?
      selected_tags = []
    end
    if selected_tags.include?(selected_tag)
      selected_tags.delete selected_tag
    else
      selected_tags.unshift selected_tag
    end
    session[:selected_tags] = selected_tags
    redirect_to :back, flash: {new_tag: selected_tag}
  end

  def tags_to_url(tags_id_array)
    return '' if tags_id_array.blank?
    ft = tags_id_array.shift
    tags_id_array.inject("#{ft}") do |str, tag|
      "#{str},#{tag}"
    end
  end

end
