#!/bin/bash

set -e

# This script installs a pip package in compute instance azureml_py310_sdkv2 environment.

sudo -u azureuser -i <<'EOF'

ENVIRONMENT=azureml_py310_sdkv2 
conda activate "$ENVIRONMENT"
pip install azure-ai-ml==1.12.1
conda deactivate
EOF
