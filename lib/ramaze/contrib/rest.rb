Ramaze::Route['REST dispatch'] = lambda{|path, request|
  case request.request_method
  when 'GET'
    path << 'show/'
  when 'POST'
    path << 'create/'
  when 'PUT'
    path << 'update/'
  when 'DELETE'
    path << 'destroy/'
  else
    path
  end
}
