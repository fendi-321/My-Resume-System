# # Resume App - Terraform Commands
.PHONY: init plan apply destroy status template push

# Local Docker Desktop
init:
	cd local && terraform init

plan:
	cd local && terraform plan

apply:
	cd local && terraform apply -auto-approve

destroy:
	cd local && terraform destroy -auto-approve

refresh:
	cd local && terraform apply -auto-approve

status:
	kubectl get all -n resume-app && echo "---" && kubectl get pods -n resume-app -o wide

# Build Docker image
build:
	docker build -t resume-app:latest ..

push:
	docker tag resume-app:latest asia-southeast1-docker.ppkg.dev/maffindi/resume-app/resume-app:latest
	docker push asia-southeast1-docker.ppkg.dev/maffindi/resume-app/resume-app:latest

# Full fresh deploy (build + wait for namespace + apply)
deploy: build
	@echo "Removing old namespace..."
	-kubectl delete namespace resume-app --wait=false 2>/dev/null
	@echo "Waiting for namespace to terminate..."
	@while kubectl get namespace resume-app >/dev/null 2>&1; do printf "."; sleep 2; done
	@echo ""
	@echo "Namespace terminated. Deploying fresh..."
	cd local && terraform apply -auto-approve

# Show all available commands
help:
	@echo "Resume App - Terraform Commands"
	@echo "==============================="
	@echo "make init       - Initialize Terraform"
	@echo "make plan       - Preview changes"
	@echo "make apply      - Deploy/update (fast, no rebuild)"
	@echo "make destroy    - Tear down everything"
	@echo "make status     - Show pod/service status"
	@echo "make build      - Build Docker image"
	@echo "make deploy     - Full fresh deploy (build + namespace cleanup + apply)"
	@echo ""

template-save:
	@echo "Saving current state as template..."
	@echo "  - Terraform state: local/terraform.tfstate"
	@echo "  - Docker image: resume-app:latest"
	@echo "  - Config files: k8s/, terraform/"
	@echo "  - Database init: terraform/init.sql (uses update_my_cv.sql)"
	@echo ""
	@echo "To restore from template, run: make deploy"
