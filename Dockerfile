From ruby:latest

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app

RUN bundle install

CMD START bundle exec ruby main.rb

