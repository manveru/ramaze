require "rubygems"
require "ramaze"

class MainController < Ramaze::Controller
  engine :Tenjin

  def index
    %{ #{a('Home',:/)} | #{a(:internal)} | #{a(:external)} }
  end

  def internal(*args)
    @args = args
    @place = :internal
    <<'__TENJIN__'
<html>
  <head>
    <title>Template::Tenjin #{@place}</title>
  </head>
  <body>
  <h1>The #{@place} Template for Tenjin</h1>
  <a href="#{r(:/)}">Home</a>
  <p>
  Here you can pass some stuff if you like, parameters are just passed like this:<br />
  <a href="#{r(@place, :one)}">#{r(@place, :one)}</a><br />
  <a href="#{r(@place, :two, :three)}">#{r(@place, :two, :three)}</a><br />
  <a href="#{r(@place, :one, :foo => :bar)}">#{r(@place, :one, :foo => :bar)}</a>
  </p>

  <div>
    The arguments you have passed to this action are:<br />
    <?rb if @args.empty? ?>
      none
    <?rb else ?>
      <?rb @args.each do |arg| ?>
        <span>#{arg}</span>
      <?rb end ?>
    <?rb end ?>
  </div>

  <div>#{request.params.inspect}</div>
  </body>
</html>
__TENJIN__
  end

  def external(*args)
    @args = args
    @place = :external
  end
end

Ramaze.start :file => __FILE__
