FROM ruby:4.0.1-slim

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    libpq-dev \
    postgresql-client \
    libyaml-dev \
    curl \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock* ./
RUN bundle install --jobs 4 --retry 3

COPY . .

RUN mkdir -p tmp/pids

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
