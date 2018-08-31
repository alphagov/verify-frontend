require 'concurrent'
require 'date'

class LoadingCache
  include Concurrent::Async
  def initialize(object, refresh_proc)
    @last_updated = :never
    @object = object
    @refresh_proc = refresh_proc
  end

  def fetch!
    result = self.await.fetch_object!
    if(result.fulfilled?)
      return result.value
    else
      raise result.reason
    end
  end

  def fetch_object!
    if need_to_refresh?
      refresh!
    end
    @object
  end

private

  def refresh!
    @object = @refresh_proc.call(@object)
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
