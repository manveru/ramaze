#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  # LinkHelper is included into the Controller by default
  #
  # Usage is pretty much shown in test/tc_helper and the rdocs below.

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
    #   A('title')                  #=> <a href="/title">title</a>
    #   A('foo/bar')                #=> <a href="/foo/bar">foo/bar</a>
    #   A('Home' :href => Rs(:/))   #=> <a href="/foo/bar">foo/bar</a>

    def A(title, hash = {})
      hash[:href] ||= Rs(title)
      hash[:href].to_s.gsub!(/[^\/]+/){|m| CGI.escape(m) }

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
      args, atoms = atoms.partition{|a| a.is_a?(Hash) }
      args = args.flatten.inject{|s,v| s.merge!(v) }

      map = Global.mapping.invert
      atoms.map! do |atom|
        if atom.respond_to?(:new)
          map[atom] || atom
        else
          map[atom.class] || atom
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

    # Uses R with self as first element.

    def Rs(*atoms)
      R(self, *atoms)
    end
  end
end
