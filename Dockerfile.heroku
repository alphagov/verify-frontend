# Dockerfile for Heroku Review App (deployed as part of a PR)

FROM ruby:2.5.5

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_ENV production
ENV SECRET_KEY_BASE notused
ENV STUB_MODE true

ADD Gemfile Gemfile

RUN gem install --update bundler

RUN bundle install --binstubs

ADD . /verify-frontend/

WORKDIR /verify-frontend

RUN bundle config --global frozen 1 && \
    bundle check || bundle install --without development test

RUN echo 'heroku' > /verify-frontend/.build-number

RUN bash -c 'source .env \
             && export $(cut -d= -f1 .env) \
             && bundle exec rake assets:precompile' \
    && ln -s /verify-frontend/public/assets /assets

# Puma needs these dockerignored dirs to write to
RUN mkdir -p log tmp

