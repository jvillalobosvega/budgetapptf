locals {
  ssh_private_key = file(var.ssh_private_key_file)
}

resource "google_compute_instance" "budget_app" {
  name         = var.vm_name
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["budget-app", "basic", "web"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e

    # ====== SWAP ======
    fallocate -l ${var.swap_size}G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

    # ====== SISTEMA ======
    apt-get update -y 
    apt-get install -y software-properties-common curl git unzip nginx ufw mariadb-server sqlite3

    # ====== PHP 8.2 ======
    apt-get install -y php8.2 php8.2-cli php8.2-fpm php8.2-mbstring php8.2-xml php8.2-curl php8.2-mysql php8.2-zip php8.2-bcmath
    
    export HOME=/root
    export COMPOSER_HOME=$HOME/.composer
    # ====== COMPOSER ======
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer

    # ====== NODE ======
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs

    # ====== FIREWALL ======
    ufw allow 'Nginx Full'
    ufw --force enable

    # ====== MARIADB ======
    MYSQL_ROOT_PASSWORD="${var.db_root_password}"
    MYSQL_DB="${var.db_name}"
    MYSQL_USER="${var.db_user}"
    MYSQL_PASS="${var.db_password}"

    systemctl start mariadb
    systemctl enable mariadb

    mysql -u root <<MYSQL_SCRIPT
      ALTER USER 'root'@'localhost' IDENTIFIED BY '$${MYSQL_ROOT_PASSWORD}';
      CREATE DATABASE IF NOT EXISTS $${MYSQL_DB};
      CREATE USER IF NOT EXISTS '$${MYSQL_USER}'@'%' IDENTIFIED BY '$${MYSQL_PASS}';
      GRANT ALL PRIVILEGES ON $${MYSQL_DB}.* TO '$${MYSQL_USER}'@'%';
      FLUSH PRIVILEGES;
    MYSQL_SCRIPT

    # ====== CONFIGURAR SSH PARA GIT ======

    mkdir -p /root/.ssh
    echo "${local.ssh_private_key}" > /root/.ssh/id_ed25519
    chmod 600 /root/.ssh/id_ed25519
    ssh-keyscan github.com >> /root/.ssh/known_hosts

    # ====== CLONAR PROYECTO ======
    mkdir -p /var/www/budget-app
    chown -R ${var.ssh_user}:${var.ssh_user} /var/www/budget-app
    cd /var/www
    git clone ${var.git_repo} budget-app
    cd budget-app

    # ====== CREAR .ENV ======
    echo "${file("./.env")}" > /var/www/budget-app/.env

    # ====== AJUSTAR IP EN .ENV ======
    VM_IP=$(curl -s ifconfig.me)
    sed -i "s|__VM_EXTERNAL_IP__|$VM_IP|g" /var/www/budget-app/.env

    # ====== DEPENDENCIAS PHP + NODE ======
    composer install --no-interaction --prefer-dist
    npm install
    npm run build

    # ====== CONFIGURAR LARAVEL ======
    php artisan key:generate
    php artisan migrate --force

    # ====== PERMISOS ======
    chown -R www-data:www-data /var/www/budget-app/storage /var/www/budget-app/bootstrap/cache

    # ====== NGINX ======
    cat <<NGINXCONF >/etc/nginx/sites-available/budget-app
      server {
          listen 80;
          server_name _;
          root /var/www/budget-app/public;

          index index.php index.html;

          location / {
              try_files \$uri \$uri/ /index.php?\$query_string;
          }

          location ~ \.php$ {
              include snippets/fastcgi-php.conf;
              fastcgi_pass unix:/run/php/php8.2-fpm.sock;
          }

          location ~ /\.ht {
              deny all;
          }
      }
    NGINXCONF

    ln -s /etc/nginx/sites-available/budget-app /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && systemctl reload nginx
  EOT
}

# ================================
# FIREWALL HTTP/HTTPS
# ================================
resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}
