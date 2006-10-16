module Ramaze::Template
  %w[ Ramaze Amrita2 ].each do |const|
    autoload(const, "ramaze/template/#{const.downcase}")
  end
end
