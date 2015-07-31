FROM node:0.12.7-slim
MAINTAINER Benjamin COUSIN <b.cousin@code-troopers.com>

ENV BOTDIR /opt/hubot

COPY . ${BOTDIR}
WORKDIR ${BOTDIR}
RUN npm install

CMD bin/hubot -a slack