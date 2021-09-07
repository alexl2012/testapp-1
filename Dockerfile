FROM node:8.7.0-alpine as base
WORKDIR /build
COPY package.json .

RUN npm set progress=false && \
    npm config set depth 0 && \
    npm install --only=production 

# copy production node_modules aside
RUN cp -R node_modules prod_node_modules


# ---- Test ----
# run linters, setup and tests
FROM base AS test
RUN npm install
COPY . .
RUN  npm run lint && npm run setup && npm run test

FROM base as release

WORKDIR /app

# Copy contents of dist folder to /opt/app
COPY --from=base /build/prod_node_modules ./node_modules
COPY . .

RUN addgroup -S docker && adduser -S docker -G docker

# Give ownership to daemon user
RUN ["chown", "-R", "docker:docker", "."]
USER docker

# Expose port 3000 to the network
EXPOSE 3000

CMD ["npm", "start", "--"]
