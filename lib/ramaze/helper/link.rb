#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  # LinkHelper is included into the Controller by default
  #
  # Usage is shown in spec/ramaze/helper/link.rb and the rdocs below.

  module LinkHelper

    private

    # Builds a basic <a> tag.
    #
    # `title` is mandatory, the second hash of options will be transformed into
    # arguments of the tag, :href is a special case and its segments will be
    # CGI.escaped.
    #
    # If you pass no :href, the title will be run through Rs and its result is
    # used instead. If you really want an empty href, use :href => ''
    #
    # Usage:
    #   A('title')                      #> <a href="/title">title</a>
    #   A('foo/bar')                    #> <a href="/foo/bar">foo/bar</a>
    #   A('/foo?x=y')                   #> <a href="/foo?x=y">/foo?x=y</a>
    #   A('title', :href => '/foo?x=y') #> <a href="/foo?x=y">title</a>
    #   A('Home', :href => Rs(:/))      #> <a href="/foo/bar">Home</a>

    def A(title, hash = {})
      hash[:href] ||= (Rs(title) rescue title)
      hash[:href].to_s.sub!(/\A[^\/?]+/){|m| CGI.escape(m) }

      args = ['']
      hash.each{|k,v| args << %(#{k}="#{v}") if k and v }

      %(<a#{args.join(' ')}>#{title || hash[:href]}</a>)
    end

    # Builds links out of segments.
    #
    # Pass it strings, symbols, controllers and it will produce a link out of
    # it. Paths to Controllers are obtained from Global.mapping.
    #
    # For brevity, the mapping for the example below is following:
    #   { MC => '/', OC => '/o', ODC => '/od' }
    #
    # Usage:
    #   R(MC) #=> '/'
    #   R(OC) #=> '/o'
    #   R(ODC) #=> '/od'
    #   R(MC, :foo) #=> '/foo'
    #   R(OC, :foo) #=> '/o/foo'
    #   R(ODC, :foo) #=> '/od/foo'
    #   R(MC, :foo, :bar => :x) #=> '/foo?bar=x'

    def R(*atoms)
      args, atoms = atoms.flatten.partition{|a| a.is_a?(Hash) }
      args = args.flatten.inject{|s,v| s.merge!(v) }

      map = Global.mapping.invert
      atoms.map! do |atom|
        if atom.is_a?(Ramaze::Controller)
          map[atom.class] || atom
        else
          map[atom] || atom
        end
      end

      front = atoms.join('/').squeeze('/')

      if args
        rear = args.inject('?'){|s,(k,v)| s << "#{k}=#{v};"}[0..-2]
        front + rear
      else
        front
      end
    end

    # Uses R with Controller.current as first element.

    def Rs(*atoms)
      R(Controller.current, *atoms)
    end

    # Give it a path with character to split at and one to join the crumbs with.
    # It will generate a list of links that act as pointers to previous pages on
    # this path.
    #
    # Example:
    #   breadcrumbs('/path/to/somewhere')
    #
    #   # results in this, newlines added for readability:
    #
    #   <a href="/path">path</a>/
    #   <a href="/path/to">to</a>/
    #   <a href="/path/to/somewhere">somewhere</a>

    def breadcrumbs(path, split = '/', join = '/')
      atoms = path.split(split).reject{|a| a.empty?}
      crumbs = atoms.inject([]){|s,v| s << [s.last,v]}
      bread = crumbs.map{|a| A(a[-1], :href=>(a*'/'))}
      bread.join(join)
    end
  end
end
