PROJECT_NAME := $(shell grep 'module ' go.mod | awk '{print $$2}' | sed 's/code.hellotalk.com\///g')
NAME := $(notdir $(PROJECT_NAME))
NOW := $(shell date +'%Y%m%d%H%M%S')
TAG := $(shell git describe --always --tags --abbrev=0 | tr -d "[v\r\n]")
COMMIT := $(shell git rev-parse --short HEAD| tr -d "[ \r\n\']")
VERSION_PKG := code.hellotalk.com/infra/initman
LD_FLAGS := "-extldflags -w -s -X $(VERSION_PKG).serviceName=$(NAME) -X $(VERSION_PKG).version=v$(TAG)-$(COMMIT) -X $(VERSION_PKG).buildTime=$(shell date +%Y%m%d-%H%M%S)"
DEV_TAG := "dev-"$(COMMIT)
LOCAL_TAG := "local-"$(NOW)
LATEST_TAG := "latest"

TCR_USER_LOCAL := "100015245601"
TCR_PWD_LOCAL := "eyJhbGciOiJSUzI1NiIsImtpZCI6IkVDQ1o6V1RMRDo3VkFXOkpINEM6STMzSjoyQU0zOkpQMlE6RkFIWTo2UlZDOjZRNTI6TjRRTjpXNVBXIn0.eyJvd25lclVpbiI6IjI4Mzg4MzI5MjIiLCJvcGVyYXRvclVpbiI6IjEwMDAxNTI0NTYwMSIsInRva2VuSWQiOiJjMHZrdW0zOTZqMmRkZXV1dWRyZyIsImV4cCI6MTkzMDEyMTgxNiwibmJmIjoxNjE0NzYxODE2LCJpYXQiOjE2MTQ3NjE4MTZ9.E5ydsYb1Kcy4IPFgaCPlG3Av714zoiR7PL31zN2kNfgc7XSXmXeDrnMad8skA_yJQA_hE321g3mYSl_rBRrJ38o9jgV-VjTXb7JIxQe9splgYOH_W6Kj4R6j5OqBgkcaYCPcDRNfLzca1LzX8F1mLTzWIIplrsam4-DDsbdF_KPjg9Sj1Kz_HflhfobKoS9af-xRFxjn2k2zJ7qWoDaobnZ5G_5L5Hvny6tyWCoMkdk1G5joP0AGsmXog89hOYlj-uSS6d30-wZ1sSL3w9IxKGmeqm9fTH4ZGoquXgdZPPVGID78LtC--OENqOX856hKswWiMsBc6d7CAIcVfGCbFw"
TCR_HOST_LOCAL :="ht-hk.tencentcloudcr.com"

DOCKER_NAMESPACE_TKE := ht-hk.tencentcloudcr.com
DOCKER_IMAGE_TKE := $(DOCKER_NAMESPACE_TKE)/$(PROJECT_NAME)
DEPLOY_DIR := $(HOME)/deploy
KUSTOMIZE_DIR := $(HOME)/kustomize

define DOCKERFILE

FROM ht-hk.tencentcloudcr.com/public/baseimages:latest

COPY __BIN__ /usr/local/bin
WORKDIR /
CMD ["__BIN__"]

endef
export DOCKERFILE

.PHONY: build/binary
build/binary:
	@echo "\n###### building $(NAME)"
	@go env
	@go build -ldflags=$(LD_FLAGS) -o $(NAME)

ci/binary: build/ensureGoPath
ci/binary: export GOPATH=$(abspath go)
ci/binary: export GO111MODULE=on
ci/binary: export GOPROXY=https://goproxy.cn
ci/binary: export GOPRIVATE=code.hellotalk.com
ci/binary: export GOOS=linux
ci/binary: export CGO_ENABLED=1
ci/binary: build/binary

.PHONY: build/tar
build/tar: build/binary
	@mv $(NAME) $(NAME)_$(NOW)
	@ln -sf $(NAME)_$(NOW) $(NAME) && \
		tar -zcf $(NAME).tar.gz $(NAME)_$(NOW) $(NAME) && \
		mv $(NAME)_$(NOW) $(NAME)

deploy/test:
	@cd $(DEPLOY_DIR) && git pull && ./deploy-test.sh $(PWD)/$(NAME).tar.gz

deploy/prd:
	@cd $(DEPLOY_DIR) && git pull && ./deploy-prod.sh $(PWD)/$(NAME).tar.gz

.SECONDARY: $(wildcard Dockerfile)
Dockerfile:
	@mkdir -p $(@D)
	@echo "$$DOCKERFILE" \
		| sed -e 's|__BIN__|$(NAME)|g' \
		> $@

.PHONY: build/ensureGoPath
build/ensureGoPath:
	@$(shell if [ ! -d go ]; then mkdir go;fi)

.PHONY: local-cicd
local-cicd: build/binary Dockerfile
	@docker build -q -t $(DOCKER_IMAGE_TKE):$(LOCAL_TAG) .
	@docker login -u $(TCR_USER_LOCAL) -p $(TCR_PWD_LOCAL) $(TCR_HOST_LOCAL)
	@docker push $(DOCKER_IMAGE_TKE):$(LOCAL_TAG)
	@rm $(NAME) Dockerfile
	@cd $(KUSTOMIZE_DIR)/develop/overlays/$(NAME) &&\
	kustomize edit set image default_image=$(DOCKER_IMAGE_TKE):$(LOCAL_TAG) &&\
	kustomize build . |  kubectl apply -f -

.PHONY: build-k8s
build-k8s: ci/binary Dockerfile
	@docker build -q -t $(DOCKER_IMAGE_TKE):$(DEV_TAG) .
	@docker login -u $(TCR_USER) -p $(TCR_PWD) $(TCR_HOST)
	@docker push $(DOCKER_IMAGE_TKE):$(DEV_TAG)
	@rm $(NAME) Dockerfile

build-k8s/tags: ci/binary Dockerfile
	@docker build -q -t $(DOCKER_IMAGE_TKE):$(TAG) .
	@docker tag $(DOCKER_IMAGE_TKE):$(TAG) $(DOCKER_IMAGE_TKE):$(LATEST_TAG)
	@docker login -u $(TCR_USER) -p $(TCR_PWD) $(TCR_HOST)
	@docker push $(DOCKER_IMAGE_TKE):$(TAG)
	@docker push $(DOCKER_IMAGE_TKE):$(LATEST_TAG)
	@rm $(NAME) Dockerfile


deploy-k8s/develop:
	@cd /builds &&\
	git clone https://$(CI_USERNAME):$(CI_PASSWORD)@code.hellotalk.com/devops/kustomize.git &&\
	cd kustomize/develop/overlays/$(NAME) &&\
	/usr/local/bin/kustomize edit set image default_image=$(DOCKER_IMAGE_TKE):$(DEV_TAG) &&\
	git add . &&\
	git commit -am "update $(PROJECT_NAME) develop kustomize config " &&\
	git pull &&\
	git push origin master || echo "nothing to commit"

deploy-k8s/test:
	@cd /builds &&\
	git clone https://$(CI_USERNAME):$(CI_PASSWORD)@code.hellotalk.com/devops/kustomize.git &&\
	cd kustomize/test/overlays/$(NAME) &&\
	/usr/local/bin/kustomize edit set image default_image=$(DOCKER_IMAGE_TKE):$(DEV_TAG) &&\
	git add . &&\
	git commit -am "update $(PROJECT_NAME) test kustomize config " &&\
	git pull &&\
	git push origin master || echo "nothing to commit"

deploy-k8s/prod:
	@cd /builds &&\
	git clone https://$(CI_USERNAME):$(CI_PASSWORD)@code.hellotalk.com/devops/kustomize.git &&\
	cd kustomize/prod/overlays/$(NAME) &&\
	/usr/local/bin/kustomize edit set image default_image=$(DOCKER_IMAGE_TKE):$(TAG) &&\
	/usr/local/bin/kustomize edit add label -f version:$(TAG) &&\
	git add . &&\
	git commit -am "update $(PROJECT_NAME) prod kustomize config " &&\
	git pull &&\
	git push origin master || echo "nothing to commit"

clean:
	@rm -f $(NAME)
	@rm -f $(NAME).tar.gz

fmt:
	command -v gofumpt || (WORK=$(shell pwd) && cd /tmp && GO111MODULE=on go get mvdan.cc/gofumpt && cd $(WORK))
	gofumpt -w -s -d .
	go vet "./..."

lint:
	golangci-lint run  -v

ci/lint: export GOPATH=$(abspath go)
ci/lint: export GO111MODULE=on
ci/lint: export GOPROXY=https://goproxy.cn
ci/lint: export GOPRIVATE=code.hellotalk.com
ci/lint: export GOOS=linux
ci/lint: export CGO_ENABLED=1
ci/lint: export GOPATH=$(abspath go)
ci/lint: build/ensureGoPath lint

cfg: build/binary
	env XXX_DUMP_DEMO_CFG=1 ./$(NAME) -c dummy > ./config/config.dist.toml

update:
	@curl -Ls https://code.hellotalk.com/snippets/10/raw > Makefile
	@curl -Ls https://code.hellotalk.com/snippets/2/raw > .gitlab-ci.yml
	@curl -Ls https://code.hellotalk.com/snippets/3/raw > .golangci.toml
