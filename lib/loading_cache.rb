require 'concurrent'
require 'date'

class LoadingCache
  include Concurrent::Async
  def initialize
    @last_updated = :never
    @cached_object = nil
  end

  def fetch(&blk)
    result = self.await.fetch_object(&blk)
    if(result.fulfilled?)
      return result.value
    else
      raise result.reason
    end
  end

  def fetch_object(&blk)
    if need_to_refresh?
      refresh(&blk)
    end
    @cached_object
  end

private

  def refresh
    @cached_object = yield
    @last_updated = DateTime.now
  end

  def need_to_refresh?
    never_updated? || expired?
  end

  def never_updated?
    @last_updated == :never
  end

  def expired?
    (@last_updated + lifetime).to_datetime < DateTime.now
  end

  def lifetime
    @lifetime ||= 30.minutes
  end
end
