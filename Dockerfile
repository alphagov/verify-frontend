FROM ruby:2.5.5

ADD Gemfile Gemfile

RUN bundle install

ADD . /verify-frontend/

WORKDIR /verify-frontend

# Puma needs these dockerignored dirs to write to
RUN mkdir -p log tmp

CMD bundle exec puma -e development -p 80
