FROM ruby:2.6

WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

RUN bundle install
