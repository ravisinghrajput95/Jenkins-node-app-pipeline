FROM node:alpine
WORKDIR /usr/app
COPY /server/* /usr/app/
RUN npm install
EXPOSE 8000
CMD ["npm", "start"]
