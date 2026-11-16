FROM node:24-slim

WORKDIR /app

# Copy just the workspace manifests first so `npm install` is cached
# unless a dependency actually changes.
COPY package.json package-lock.json ./
COPY packages/shared/package.json packages/shared/package.json
COPY services/api/package.json services/api/package.json

# devDependencies included: tsx/typescript are required to build.
RUN npm install

COPY packages/shared packages/shared
COPY services/api services/api

RUN npm run build --workspace=services/api

ENV PORT=3000
EXPOSE 3000

CMD ["node", "services/api/dist/server.js"]
