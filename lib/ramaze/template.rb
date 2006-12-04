module Ramaze::Template
  %w[ Ramaze Amrita2 Erubis ].each do |const|
    autoload(const, "ramaze/template/#{const.downcase}")
  end
end
