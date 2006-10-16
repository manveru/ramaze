module Ramaze::Template
  %w[ Amrita2 ].each do |const|
    autoload(const, "ramaze/template/#{const.downcase}")
  end
end
