ARG RUBY=ruby:3.4.7-alpine3.23

FROM ${RUBY} AS ghr-builder

RUN apk add --no-cache bash build-base git linux-headers file-dev yaml-dev tzdata\
  postgresql-dev gcompat make

WORKDIR /app

COPY Gemfile* /app/

COPY ./vendor/. /app/vendor/

RUN bundle config set bin /usr/local/bin

RUN bundle install -j $(getconf _NPROCESSORS_ONLN)

FROM ${RUBY} AS ghr-web

RUN apk add --no-cache bash tzdata postgresql-client gcompat less

COPY --from=ghr-builder /usr/local/ /usr/local/
COPY --from=ghr-builder /app/ /app/

WORKDIR /app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]

FROM ghr-web AS ghr

ARG REVISION=n/a

COPY . .

ENV REVISION=${REVISION}
