class Journeys
  include Rails.application.routes.url_helpers

  def initialize(&blk)
    @journeys = {}
    instance_eval(&blk)
  end

  def get_path(path, conditions = [])
    destination = @journeys[path] || raise("Path not found: #{path}")
    destination[conditions] || raise("No matching conditions on path #{path} for #{conditions}")
  end

  def at(path, params)
    @journeys[path] = { [] => params.fetch(:next) }
  end

  def branch_at(path, branches)
    @journeys[path] = branches
  end
end
