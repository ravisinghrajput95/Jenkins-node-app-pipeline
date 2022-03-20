FROM node:alpine
WORKDIR /usr/app
COPY /server/* .
COPY package-lock.json . 
RUN npm install
EXPOSE 8000
CMD ["npm", "start"]
