


ENV NODE_ENV=

# docker run --net host -e "PM2_PUBLIC_KEY=XXX" -e "PM2_SECRET_KEY=XXX" <...>
ENV PM2_PUBLIC_KEY=XXX
ENV PM2_SECRET_KEY=YYY




RUN npm install pm2 -g


#CMD ["pm2-runtime", "process.yml"]
CMD ["pm2-runtime", "process.yml", "--only", "APP"]
