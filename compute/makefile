test:
	go test ./app/

build:
	GOOS=linux GOARCH=arm go build  -o bin/generic-oranges ./app

run:
	go run ./app


all: hello build