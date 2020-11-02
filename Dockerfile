FROM ruby:2.7.2-alpine3.12

# hadolint ignore=DL3018
RUN apk add --no-cache build-base git tzdata nodejs yarn

RUN mkdir /app
WORKDIR /app

EXPOSE 3000

# Install bundler
RUN gem install bundler --version=2.1.4
RUN gem install rails

# Install Gems removing artifacts
COPY . /app

# hadolint ignore=SC2046
RUN bundle config --local deployment true
# RUN bundle config --local without "development test"
RUN bundle config set git.allow_insecure true
RUN bundle install --jobs=$(nproc --all) && \
    rm -rf /root/.bundle/cache && \
    rm -rf /usr/local/bundle/cache

# install NPM packages removign artifacts
COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean

CMD ["/app/bin/rails" , "server"  ]
