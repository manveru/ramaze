require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  LOGINS = {
   :username => 'password',
   :admin => 'secret'
  }.map{|k,v| ["#{k}:#{v}"].pack('m').strip} unless defined? LOGINS

  helper :aspect

  before_all do
    response['WWW-Authenticate'] = %(Basic realm="Login Required")
    respond 'Unauthorized', 401 unless auth = request.env['HTTP_AUTHORIZATION'] and
                                       LOGINS.include? auth.split.last
  end

  def index
    'Secret Info'
  end
end

Ramaze.start :adapter => :mongrel