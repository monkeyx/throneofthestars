class JsonController < ApplicationController
  def world_regions
    @world = World.find(params[:id])
    list = @world.regions.to_a.map do |region|
      {:value => region.id, :display => region.name}
    end
    render :text => list.to_json
  end

  def region_estates
    @region = Region.find(params[:id])
    list = @region.estates.to_a.map do |estate|
      {:value => estate.id, :display => estate.name}
    end
    render :text => list.to_json
  end

  def house_characters
    @house = NobleHouse.find(params[:id])
    list = Character.of_house(@house).living.map do |character|
      {:value => character.id, :display => character.display_name} unless character.dead?
    end
    render :text => list.to_json
  end

  def single_females
    @house = NobleHouse.find(params[:id])
    list = @house.single_females.to_a.map do |character|
      {:value => character.id, :display => character.display_name} unless character.dead?
    end
    render :text => list.to_json
  end

  def single_males
    @house = NobleHouse.find(params[:id])
    list = @house.single_males.to_a.map do |character|
      {:value => character.id, :display => character.display_name} unless character.dead?
    end
    render :text => list.to_json
  end

  def army_units
    @army = Army.find(params[:id])
    list = []
    list = @army.units.to_a.map do |unit|
      {:value => unit.id, :display => unit.name}
    end if belongs_to_current_player?(@army)
    render :text => list.to_json
  end

end
