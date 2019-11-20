# # The instructions for the first stage
FROM keymetrics/pm2:8-alpine as builder

RUN \
  apk add --no-cache python make g++ git && \
  apk add vips-dev fftw-dev --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community --repository http://dl-3.alpinelinux.org/alpine/edge/main && \
  rm -fR /var/cache/apk/*

RUN npm install -g yarn

COPY package.json ./
COPY .env ./
COPY yarn.lock ./
RUN yarn install && yarn cache clean

COPY . .
RUN yarn run build

# The instructions for second stage
FROM keymetrics/pm2:8-alpine

WORKDIR /usr/src/app
COPY --from=builder node_modules node_modules
COPY --from=builder dist dist
COPY --from=builder data data

COPY package*.json ./
ENV NODE_ENV=production

CMD [ "npm", "run", "prod" ]