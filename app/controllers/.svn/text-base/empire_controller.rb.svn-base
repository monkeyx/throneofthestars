class EmpireController < ApplicationController
  respond_to :html, :js

  def index
  	unless cached?
	    @news = News.empire
	    @emperor = Character.emperor
	    @dukes = Character.dukes
	    @worlds = World.all
	    @laws = Law.imperial_laws
	end
  end
end
