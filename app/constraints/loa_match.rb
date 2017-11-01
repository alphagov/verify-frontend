module LoaMatch
  IsLoa1 = ->(request) {
    request.session[:requested_loa] == 'LEVEL_1'
  }

  IsLoa2 = ->(request) {
    !IsLoa1.call(request)
  }
end
