# This is a multi-part build that first statically builds irccat, and then
# copies over the resulting binary and the default SSL root certs over into
# a 'scratch' image, resulting in a very small image.
#
# You must provide a config file at /etc/irccat.[json|yaml|toml|hcl], for
# example:
#
#  docker build . -t irccat
#  docker run -d -P -v /path/to/my/config/irccat.json:/etc/irccat.json irccat
#
# (This will also expose the default ports: 12345 and 8045.)

# Step one: fetch deps and build
FROM golang:latest AS build

ADD . /go/src/github.com/irccloud/irccat
WORKDIR /go/src/github.com/irccloud/irccat

RUN CGO_ENABLED=0 go get -t -v ./... && go build -a .

# Step two: copy over the binary and root certs
FROM debian:buster
COPY --from=build /go/bin/irccat /irccat

RUN apt update && apt install -y \
	python3 \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

EXPOSE 12345
EXPOSE 8045

CMD ["/irccat"]
