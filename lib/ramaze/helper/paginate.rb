require 'ramaze/gestalt'

module Ramaze
  module Helper
    module Paginate
      trait :paginate => {
        :limit => 10,
        :var   => 'pager',
      }

      def paginate(dataset, hash = {})
        options = ancestral_trait[:paginate].merge(hash)
        limit = options[:limit]
        var   = options[:var]
        page  = options[:page] || (request[var] || 1).to_i

        Paginator.new(dataset, page, limit, var)
      end

      class Paginator
        include Ramaze::Helper::Link
        include Ramaze::Helper::CGI

        def initialize(data = [], page = 1, limit = 10, var = 'pager')
          @data, @page, @limit, @var = data, page, limit, var
          @pager = pager_for(data)
        end

        def pager_for(obj)
          case obj
          when Array
            ArrayPager.new(obj, @page, @limit)
          else
            obj.paginate(@page, @limit)
          end
        end

        def navigation
          out = [ g.div(:class => :pager) ]

          if first_page?
            out << g.span(:class => 'first grey'){ '<<' }
            out << g.span(:class => 'previous grey'){ '<' }
          else
            out << link(1, '<<', :class => :first)
            out << link(prev_page, '<', :class => :previous)
          end

          (1...current_page).each do |n|
            out << link(n)
          end

          out << link(current_page, current_page, :class => :current)

          if last_page?
            out << g.span(:class => 'next grey'){ '>' }
            out << g.span(:class => 'last grey'){ '>>' }
          else
            (next_page..page_count).each do |n|
              out << link(n)
            end

            out << link(next_page, '>', :class => :next)
            out << link(page_count, '>>', :class => :last)
          end

          out << '</div>'
          out.map{|e| e.to_s}.join("\n")
        end

        def link(n, text = n, hash = {})
          text = h(text.to_s)

          params = Ramaze::Request.current.params.merge(@var => n)
          hash[:href] = Rs(Ramaze::Action.current.name, params)

          g.a(hash){ text }
        end

        def g
          Ramaze::Gestalt.new
        end

        def needed?
          @pager.page_count > 1
        end

        def method_missing(meth, *args, &block)
          @pager.send(meth, *args, &block)
        end

        class ArrayPager
          def initialize(array, page, limit)
            @array, @page, @limit = array, page, limit
            @page = page_count if @page > page_count
          end

          def size
            @array.size
          end

          def empty?
            @array.empty?
          end

          def page_count
            pages, rest = @array.size.divmod(@limit)
            rest == 0 ? pages : pages + 1
          end

          def current_page
            @page
          end

          def next_page
            page_count == @page ? nil : @page + 1
          end

          def prev_page
            @page <= 1 ? nil : @page - 1
          end

          def first_page?
            @page <= 1
          end

          def last_page?
            page_count == @page
          end

          def each(&block)
            from = ((@page - 1) * @limit)
            to = from + @limit

            a = @array[from...to] || []
            a.each(&block)
          end

          include Enumerable
        end

      end
    end
  end
end
