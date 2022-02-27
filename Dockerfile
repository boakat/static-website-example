FROM alpine:latest
MAINTAINER  boakat(akaboidi@hotmail.fr)
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git nginx
RUN rm -rf /var/www/html/*
RUN git clone https://github.com/diranetafen/static-website-example.git /var/www/html/
RUN adduser -D myuser
USER myuser
EXPOSE 5000
ENTRYPOINT ["/usr/sbin/nginx","-g","daemon off;"]
# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku			
CMD gunicorn --bind 0.0.0.0:$PORT wsgi


