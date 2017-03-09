class Journeys
  include Rails.application.routes.url_helpers

  def initialize(&blk)
    @journeys = instance_eval(&blk)
  end

  def get_path(path)
    @journeys[path] || raise("Path not found: #{path}")
  end
end
