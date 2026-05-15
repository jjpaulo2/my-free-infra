
TERRAFORM_PATH := terraform/production

ANSIBLE_SSH_KEYS := ansible/ssh
ANSIBLE_INVENTORY_FOLDER := ansible/inventory
ANSIBLE_INVENTORY := $(ANSIBLE_INVENTORY_FOLDER)/production

NODE_0_PUBLIC_IP := $(shell terraform -chdir=$(TERRAFORM_PATH) output -raw node_0_public_ip)
NODE_1_PUBLIC_IP := $(shell terraform -chdir=$(TERRAFORM_PATH) output -raw node_1_public_ip)
NODE_HEAVY_0_PUBLIC_IP := $(shell terraform -chdir=$(TERRAFORM_PATH) output -raw node_heavy_0_public_ip)

ansible/ssh:
	@mkdir -p $(ANSIBLE_SSH_KEYS)
	@terraform -chdir=$(TERRAFORM_PATH) output -raw node_0_ssh_private_key > $(ANSIBLE_SSH_KEYS)/node_0.key
	@terraform -chdir=$(TERRAFORM_PATH) output -raw node_1_ssh_private_key > $(ANSIBLE_SSH_KEYS)/node_1.key
	@terraform -chdir=$(TERRAFORM_PATH) output -raw node_heavy_0_ssh_private_key > $(ANSIBLE_SSH_KEYS)/node_heavy_0.key
	@chmod 600 $(ANSIBLE_SSH_KEYS)/*

ansible/inventory:
	@mkdir -p $(ANSIBLE_INVENTORY_FOLDER)
	@echo "node_0 ansible_host=$(NODE_0_PUBLIC_IP) ansible_ssh_private_key_file=ssh/node_0.key" >> $(ANSIBLE_INVENTORY)
	@echo "node_1 ansible_host=$(NODE_1_PUBLIC_IP) ansible_ssh_private_key_file=ssh/node_1.key" >> $(ANSIBLE_INVENTORY)
	@echo "node_heavy_0 ansible_host=$(NODE_HEAVY_0_PUBLIC_IP) ansible_ssh_private_key_file=ssh/node_heavy_0.key" >> $(ANSIBLE_INVENTORY)