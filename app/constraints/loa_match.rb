module LoaMatch
  is_loa = ->(level, _, request) {
    request.session['requested_loa'] == level
  }

  IsLoa1 = is_loa.curry.('LEVEL_1')
  IsLoa2 = is_loa.curry.('LEVEL_2')
end
