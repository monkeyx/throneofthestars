class ChurchController < ApplicationController
  respond_to :html, :js

  def index
  	unless cached?
	    @news = News.church
	    @pontiff = Character.pontiff
	    @archbishops = Character.archbishops
	    @worlds = World.all
	    @edicts = Law.church_edicts
	end
  end
end
