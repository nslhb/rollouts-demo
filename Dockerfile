FROM golang:1.16.3 AS build
WORKDIR /go/src/app
COPY . .
RUN make

FROM alpine:3.12.0
COPY *.html ./
COPY *.png ./
COPY *.js ./
COPY *.ico ./
COPY *.css ./
COPY --from=build /go/src/app/rollouts-demo /rollouts-demo

ARG COLOR
ENV COLOR=${COLOR}
ARG ERROR_RATE
ENV ERROR_RATE=${ERROR_RATE}
ARG LATENCY
ENV LATENCY=${LATENCY}

ENTRYPOINT [ "/rollouts-demo" ]