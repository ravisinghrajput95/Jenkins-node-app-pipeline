FROM node:17-alpine

COPY --chown=node:node . /opt/app

RUN npm i && \
    chmod 775 -R ./node_modules/ && \
    npm run build && \
    npm prune --production && \
    mv -f dist node_modules package.json package-lock.json /tmp && \
    rm -f -R * && \
    mv -f /tmp/* . && \
    rm -f -R /tmp

ENV NODE_ENV production

EXPOSE 8000

USER node

CMD ["node", "./dist/bundle.js"]
