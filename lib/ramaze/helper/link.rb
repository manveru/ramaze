#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  # LinkHelper is included into the Controller by default
  #
  # this helper tries to get along without any major magic, the only 'magic'
  # thing is that it looks up controller-paths if you pass it a controller
  # the text shown is always the last segmet of the finished link from split('/')
  #
  # usage is pretty much shown in test/tc_helper
  # however, to give you some idea of how it actually works, some examples:
  #
  # link MainController, :foo                 #=> '<a href="/foo">foo</a>'
  # link MinorController, :foo                #=> '<a href="/minor/foo">foo</a>'
  # link MinorController, :foo, :bar          #=> '<a href="/minor/foo/bar">bar</a>'
  # link MainController, :foo, :raw => true   #=> '/foo'
  # link MainController, :foo => :bar         #=> '/?foo=bar'
  #
  # link_raw MainController, :foo             #=> '/foo'
  # link_raw MinorController, :foo            #=> '/minor/foo'
  # link_raw MinorController, :foo, :bar      #=> '/minor/foo/bar'
  #
  # TODO:
  #   - handling of no passed parameters
  #   - setting imagelinks
  #   - setting of id or class
  #   - taking advantae of Gestalt to build links
  #   - lots of other minor niceties, for the moment i'm only concerned to keep
  #     it as simple as possible
  #

  module LinkHelper

    private

    def A(title, hash = {})
      hash[:href] ||= Rs(title)
      hash[:href].to_s.gsub!(/[^\/]+/){|m| CGI.escape(m) }

      args = ['']
      hash.each{|k,v| args << %(#{k}="#{v}") if k and v }

      %(<a#{args.join(' ')}>#{title || hash[:href]}</a>)
    end

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

    def Rs(*atoms)
      R(self, *atoms)
    end
  end
end
