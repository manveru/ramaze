require 'set'

# require 'ramaze/contrib/app_graph'
#
# graph = AppGraph.new
# graph.generate
# graph.show

class AppGraph
  def initialize
    @out = Set.new
  end

  def generate
    Ramaze::AppMap.to_hash.each do |location, app|
      connect(location => app.name)

      app.url_map.to_hash.each do |c_location, c_node|
        connect(app.name => c_node)
        connect(c_node.mapping => c_node)

        c_node.update_template_mappings
        c_node.view_templates.each do |wish, mapping|
          mapping.each do |action_name, template|
            action_path = File.join(c_node.mapping, action_name)
            connect(c_node => action_path, action_path => template)
          end
        end

        c_node.update_method_arities
        c_node.method_arities.each do |method, arity|
          action_path = File.join(c_node.mapping, method.to_s)
          connect(action_path => "#{c_node}##{method}[#{arity}]", c_node => action_path)
        end
      end
    end
  end

  def connect(hash)
    hash.each do |from, to|
      @out << ("  %p -> %p;" % [from.to_s, to.to_s])
    end
  end

  def write_dot
    File.open('graph.dot', 'w+') do |dot|
      dot.puts 'digraph appmap {'
      dot.puts(*@out)
      dot.puts '}'
    end
  end

  def show
    write_dot
    options = {
      'rankdir' => 'LR',
      'splines' => 'true',
      'overlap' => 'false',
    }
    args = options.map{|k,v| "-G#{k}=#{v}" }
    system("dot -O -Tpng #{args.join(' ')} graph.dot")
    system('feh graph.dot.png')
  end
end
