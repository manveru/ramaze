# auto_params.rb
#
# AutoParams implements action parameterization ala merb 0.4 and Nitro
# using ruby2ruby and ParseTree
#
# Usage:
#   require 'ramaze/contrib'
#   Ramaze.contrib :auto_params
#
# For example,
#
#   def search(query) end
#
# can be accessed via
#
#   - /search?query=findthis, which calls search('findthis')
#   - /search/findthis                    search('findthis')
#   - /search/findthis?query=andthis      search(['findthis', 'andthis'])
#
# For more examples, take a look at spec/contrib/auto_params.rb
#
# Note: A simpler alternative for similar functionality would be:
#
#   def search(query = request['query']) end
#

require __DIR__/:auto_params/:get_args

module Ramaze

  module Contrib
    class AutoParams
      def self.startup
        Ramaze::Cache.add :args
      end
    end
  end

  class Action

    # with parameterization, params may include
    #   arrays: /num?n=1&n=2 becomes [['1','2']] for def num(n) end
    #   nil: /calc?w=10&d=2 becomes ['10', nil, '2'] for def calc(w, h, d) end

    def params=(*par)
      par = *par
      self[:params] = par.map{ |pa|
        case pa
        when Array
          pa.map{|p| CGI.unescape(p.to_s)}
        when nil
          nil
        else
          CGI.unescape(pa.to_s)
        end
      } unless par.nil?
      self[:params] ||= []
    end

  end

  class Controller

    # ignore cache when request.params is interesting

    def self.cached(path)
      if found = Cache.resolved[path]
        if found.respond_to?(:relaxed_hash)

          # don't use cache if we need to add request.params entries to the Action
          if args = Cache.args[found.method]
            param_keys = request.params.keys
            return nil if args.find{|k,v| param_keys.include?(k.to_s) }
          end

          return found.dup
        else
          Inform.warn("Found faulty `#{path}' in Cache.resolved, deleting it for sanity.")
          Cache.resolved.delete path
        end
      end

      nil
    end

    # use Method#get_args to insert values from request.params into Action#params

    def self.resolve_method(name, *params)
      if method = action_methods.delete(name)
        meth = instance_method(method)
        arity = meth.arity

        if meth.respond_to? :get_args
          Cache.args[name] ||= meth.get_args.select{|e| e.to_s !~ /^\*/} || []
          args = Cache.args[name]

          param_keys = request.params.keys

          # if there are missing args, or keys in request.params that match expected args
          if args.size > params.size or args.find{|k,v| param_keys.include?(k.to_s) }
            args.each_with_index do |(name, val), i|
              r_params = request.params[name.to_s]
              if params[i] and r_params.size > 0
                params[i] = [params[i], r_params].flatten
              else
                params[i] ||= r_params
              end
            end

            # strip trailing nils so default argument values are used
            params.reverse.each{|e| if e.nil? then params.pop else break end }
          end

          argity = args.select{|e| e.size==1}.size..args.size
        else
          argity = arity..arity
        end

        if arity < 0 or argity.include? params.size
          return method, params
        end
      end
      return nil, []
    end

  end

end