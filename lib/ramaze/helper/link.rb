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

    # Usage:
    #   link MainController, :foo                 #=> '<a href="/foo">foo</a>'
    #   link MinorController, :foo                #=> '<a href="/minor/foo">foo</a>'
    #   link MinorController, :foo, :bar          #=> '<a href="/minor/foo/bar">bar</a>'
    #   link MainController, :foo, :raw => true   #=> '/foo'
    #   link MainController, :foo, :title => 'a'  #=> '<a href="/minor/foo/bar">a</a>'
    #   link MainController, :foo => :bar         #=> '/?foo=bar'

    def Rlink *to
      hash = to.last.is_a?(Hash) ? to.pop : {}

      to = to.flatten

      to.map! do |t|
        t = t.class if not t.respond_to?(:transform) and t.is_a?(Controller)
        Global.mapping.invert[t] || t
      end

      raw, title = hash.delete(:raw), hash.delete(:title)
      params = {:class => hash.delete(:class), :id => hash.delete(:id)}
      opts = hash.inject('?'){|s,(k,v)| s << "#{k}=#{v};"}[0..-2]
      link = to.join('/').squeeze('/') << (opts.empty? ? '' : opts)

      if raw
        link
      else
        title ||= link.split('/').last.to_s.split('?').first || 'index'
        params = params.inject(''){|s,(k,v)| s + (k and v ? %{ #{k}="#{v}"} : '')}
        l = %{<a href="#{link}"#{params}>#{title}</a>}
      end
    end

    alias link Rlink

    # Usage:
    #   R MainController, :foo        #=> '/foo'
    #   R MinorController, :foo       #=> '/minor/foo'
    #   R MinorController, :foo, :bar #=> '/minor/foo/bar'

    def R *to
      if to.last.is_a?(Hash)
        to.last[:raw] = true
      else
        to << {:raw => true}
      end

      Rlink(*to)
    end

    def Rs(*to)
      R(self, *to)
    end
  end
end
