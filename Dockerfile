FROM ruby:3.0.6

# Install dependencies and psql in container
RUN apt-get update -qq && apt-get install -y postgresql-client

WORKDIR /app

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

COPY . .

# give permission to execute the entrypoint
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
