export PATH := $(PWD)/tools/apache-maven-3.9.1/bin:$(PWD)/tools/:$(PATH)
export GITHOSTNAME := github.com
export GITUSERID := pinionengineering
export GITREPOID := pinning-service-models
export TYPEMAPPING := "TextMatchingStrategy=string"


ipfs-pinning-service.yaml:
	curl -sLO https://raw.githubusercontent.com/ipfs/pinning-services-api-spec/main/ipfs-pinning-service.yaml


# https://openapi-generator.tech/docs/installation#bash-launcher-script
TOOLS+=tools/openapi-generator-cli
tools/openapi-generator-cli:
	mkdir -p tools
	curl -sLo tools/openapi-generator-cli https://raw.githubusercontent.com/OpenAPITools/openapi-generator/master/bin/utils/openapi-generator-cli.sh
	chmod +x tools/openapi-generator-cli

TOOLS+=tools/mvn
tools/mvn:
	mkdir -p tools
	curl -sL https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz | tar -C tools/ -xzf -


.PHONY: generate
generate: $(TOOLS) ipfs-pinning-service.yaml
	openapi-generator-cli generate \
		--input-spec ipfs-pinning-service.yaml  \
		--git-host $(GITHOSTNAME)  \
		--git-user-id $(GITUSERID) \
		--git-repo-id $(GITREPOID) \
		--generate-alias-as-model \
		--generator-name go-server \
		--additional-properties packageName=server,sourceFolder=server,router=mux
	go mod tidy
	go fmt ./...


.PHONY: test
test:
	go test ./...


.PHONY: clean
clean:
	rm -rf tools/ ipfs-pinning-service.yaml api/ server/ main.go go.sum go.mod Dockerfile
