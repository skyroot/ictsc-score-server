#!/usr/bin/env ruby
# Coding: UTF-8

Dotenv.load
Bundler.require(ENV["RACK_ENV"]) if ENV["RACK_ENV"]

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))

require_relative "db/model"

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :development do
    use BetterErrors::Middleware
    BetterErrors.application_root = settings.root
  end

  configure do
    Time.zone = "Tokyo"
    ActiveRecord::Base.default_timezone = :local

    def logger
      env['app.logger'] || env['rack.logger']
    end

    register Sinatra::RocketIO

    # set :cometio, timeout: 120, post_interval: 2, allow_crossdomain: false
    # set :websocketio, port: 9000
    # set :rocketio, websocket: true, comet: true # enable WebSocket and Comet

    enable :prefixed_redirects
    set :haml, { escape_html: false, format: :html5 }
    set :scss, style: :expanded
    set :database, { adapter: "sqlite3", database: "db/#{settings.environment}.sqlite3" }

    # I18n.enforce_available_locales = false
    I18n.load_path = Dir[File.join(settings.root, "locales", "*.yml")]
    I18n.backend.load_translations
    I18n.locale = :ja
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  get "/?" do
    haml :index
  end

  get "/:name.html" do
    redirect to(params[:name])
  end

  # get "/test/:message" do
  #   Sinatra::RocketIO.push :message, params[:message]

  #   200
  # end

  get "/signin" do
    @title = "SIGN IN"
    haml :signin
  end

  get "/problems" do
    @title = "PROBLEM"
    haml :problems
  end

  get "/users" do

  end

  get "/score" do

  end

  get "/answers" do
    @title = "ANSWERS"
    haml :answer
  end

  get "/issues" do
    @title = "ISSUES"
    haml :issues
  end

  # get "/notifications" do

  # end

  get "/manage" do

  end

  not_found do
    { error: "not found" }.to_json
  end

  get "/css/*" do
    file_name = params[:splat].first
    views =  Pathname(settings.views)

    if File.exists?(views + "css" + file_name)
      send_file views + "css" + file_name
    elsif File.exists?(views + "scss" + file_name.sub(%r{.css$}, ".scss"))
      scss :"scss/#{file_name.sub(%r{.css$}, "")}"
    else
      halt 404
    end
  end

  get "/js/*.js" do
    file_name = params[:splat].first
    views =  Pathname(settings.views)

    if File.exists?(views + "js" + "#{file_name}.js")
      send_file views + "js" + "#{file_name}.js"
    else
      halt 404
    end
  end
end
