FROM node:alpine
WORKDIR /usr/app
COPY /server/* ./
COPY package-lock.json . 
RUN cd /src
RUN npm install
EXPOSE 8000
CMD ["node", "run", "watch"]
