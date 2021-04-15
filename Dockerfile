FROM ruby:2.6.5-buster

SHELL ["/bin/bash", "--login", "-c"]


# nodejs install
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get update -qq \
  && apt-get install -y nodejs


# yarn install
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update && apt install -y yarn


# for rails-erd
RUN apt-get install -y graphviz


# project build
COPY . /project

WORKDIR /project

RUN bundle install --jobs=4 \
  && yarn install --check-files


# entrypoint
ENTRYPOINT ["/project/entrypoint.sh"]


# envs
ENV TZ Asia/Tokyo
ENV LANG C.UTF-8
