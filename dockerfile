
FROM ruby:latest
COPY http_server /app
USER root
RUN useradd adjust
RUN chown -R adjust /app
USER adjust
WORKDIR /app
EXPOSE 80
CMD ["ruby", "/app/http_server.rb"]