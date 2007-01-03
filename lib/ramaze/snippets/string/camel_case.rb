class String
  def camel_case
    split('_').map{|e| e.capitalize}.join
  end
end

