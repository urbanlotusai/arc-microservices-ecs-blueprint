.DEFAULT_GOAL := help
.PHONY: help fmt init validate plan apply clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

fmt: ## Format Terraform files
	terraform fmt -recursive

init: ## Initialise (no backend)
	terraform init -backend=false

validate: init ## Validate
	terraform validate

plan: ## Plan
	terraform plan

apply: ## Apply
	terraform apply

clean: ## Clean
	rm -rf .terraform .terraform.lock.hcl tfplan *.tfplan
