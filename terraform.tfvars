project_id = "budget-app-477622"

# ===== VM =====
vm_name           = "budget-app"
region            = "us-east1"
zone              = "us-east1-b"
disk_size         = 20         # 20 GB máximo Free Tier
swap_size         = 1          # 1 GB swap

# ===== MYSQL =====
db_root_password  = "rootpass123"
db_name           = "churchaccounting"
db_user           = "budget_user"
db_password       = "budgetpass123"

# ===== GIT =====
git_repo          = "https://github.com/jvillalobosvega/churchaccounting.git"

# ===== SSH =====
ssh_user          = "jose"
ssh_private_key_path = "~/.ssh/google_compute_engine"