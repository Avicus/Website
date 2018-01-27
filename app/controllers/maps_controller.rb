class MapsController < ApplicationController

  before_action :category_select
  skip_before_action(:check_bans)

  def self.permission_definition
    {
        :global_options => {
            :text => 'Maps',
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :actions => {:view => [:feedback]}
                              }]
    }
  end

  def index
    @maps = $maps.values
    @total = @maps.size
    require 'will_paginate/array'
    @maps = @maps.paginate(:page => params[:page], :per_page => 20)
  end

  def category
    @cat = $categorized_maps[params['cat']]
    if @cat.nil?
      render_404
      return
    end

    require 'will_paginate/array'
    @total = @cat.size
    @cat = @cat.paginate(:page => params[:page], :per_page => 20)
  end

  def map
    @map = $maps[params['map']]
    if @map.nil?
      render_404
      return
    end
  end

  def ratings
    @map = $maps[params['map']]
    @version = params['version'].gsub('_', '.')
    @ratings = @map.ratings_breakdown(@version).values
    @versions = @map.versions
    @average = @map.ratings_average(@version)
    render :layout => false
  end

  private

  def category_select
    @category_select = {'- Map Categories -' => nil, 'ALL MAPS' => '/maps'}
    $categorized_maps.keys.sort_by { |cat| cat }.each do |cat|
      @category_select[cat] = '/maps/category/' + cat
    end
  end
end
