require "ssl_context_factory"
ssl_context = SSLContextFactory.new.create_context
HTTP.default_options = { ssl_context: ssl_context }
HTTP.timeout(:global, read: CONFIG.read_timeout, connect: CONFIG.connect_timeout)
