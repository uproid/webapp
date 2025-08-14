FROM dart:stable AS build
WORKDIR /www

ENV WIDGETS_PATH=./lib/widgets
ENV WIDGETS_TYPE=j2.html
ENV LANGUAGE_PATH=./lib/languages
ENV PUBLIC_DIR=./public
ENV LOCAL_DEBUG=true
ENV ENABLE_DATABASE=true

COPY . .

# Create .env file
RUN echo "MYSQL_HOST=mysql" > .env && \
    echo "MONGO_CONNECTION=mongodb" >> .env && \
    echo "MONGO_PORT=27017" >> .env

#RUN chmod -R a+rxw .
RUN dart pub get 
RUN dart pub get --offline 


EXPOSE 8085 8181

CMD [ "dart","run","--enable-asserts", "--observe=8181", "--enable-vm-service", "--disable-service-auth-codes","/www/lib/watcher.dart", "migrate", "--init" ]