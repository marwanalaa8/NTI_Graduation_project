
FROM node:18-alpine AS build

WORKDIR /app

ARG VITE_APP_API_ENDPOINT_URL
ARG VITE_APP_TMDB_V3_API_KEY

ENV VITE_APP_API_ENDPOINT_URL=${VITE_APP_API_ENDPOINT_URL}
ENV VITE_APP_TMDB_V3_API_KEY=${VITE_APP_TMDB_V3_API_KEY}

COPY ./package.json ./yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build


FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY ./nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
