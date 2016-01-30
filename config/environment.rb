# Load the rails application
require File.expand_path('../application', __FILE__)

require 'bb-ruby'
require 'log'
require 'ancient_house'
require 'chance'
require 'dice'
require 'events'
require 'game_date'
require 'game_updater'
require 'house_position'
require 'item_container'
require 'locatable'
require 'names'
require 'news_log'
require 'number_formatting'
require 'order_dispatcher'
require 'raw_materials'
require 'signup'
require 'timer'
require 'wealthy'
require 'starships'

# Initialize the rails application
Throneofthestars::Application.initialize!

$UID = UUID.new

$ROOT_URL = "thronestars.com" if Rails.env == 'production'
$ROOT_URL = "localhost:3000" unless $ROOT_URL
$EMAIL_ADDRESS = 'gm@thronestars.com'

$WIKI_BASE = "http://throneofthestars.wikia.com/wiki/"
$WIKI_HOME = "#{$WIKI_BASE}Throne_of_the_Stars_Wiki"
$FORUM_HOME = "http://thronestars.proboards.com"

$DEV_STATUS_POST = "http://thronestars.proboards.com/index.cgi?board=news&action=display&thread=1"