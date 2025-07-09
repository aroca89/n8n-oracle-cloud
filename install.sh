#!/bin/bash

# Script de instalación de n8n para Oracle Cloud
# Autor: Configuración para automatizaciones privadas
# Fecha: 2025

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Instalando n8n en Oracle Cloud${NC}"
echo "=================================================="

# Función para logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Verificar si es root
if [[ $EUID -eq 0 ]]; then
   error "No ejecutes este script como root. Usa un usuario normal con sudo."
fi

# Actualizar sistema
log "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias básicas
log "Instalando dependencias básicas..."
sudo apt install -y curl wget git vim htop unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Instalar Docker
log "Instalando Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    log "Docker instalado. Necesitarás cerrar sesión y volver a entrar para usar Docker sin sudo."
else
    log "Docker ya está instalado."
fi

# Instalar Docker Compose
log "Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    log "Docker Compose ya está instalado."
fi

# Configurar firewall para Oracle Cloud
log "Configurando firewall..."
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Configurar iptables para Oracle Cloud (necesario para el firewall interno)
log "Configurando iptables para Oracle Cloud..."
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 5678 -j ACCEPT
sudo netfilter-persistent save

# Crear directorio del proyecto
PROJECT_DIR="$HOME/n8n-server"
log "Creando directorio del proyecto en $PROJECT_DIR..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Descargar archivos del repositorio
log "Descargando archivos de configuración..."
curl -fsSL https://raw.githubusercontent.com/aroca89/n8n-oracle-cloud/main/docker-compose.yml -o docker-compose.yml

# Crear estructura de directorios
log "Creando estructura de directorios..."
mkdir -p {nginx,certbot/{conf,www},workflows,credentials,backups,scripts}

# Generar claves de encriptación seguras
log "Generando claves de seguridad..."
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -base64 32)
N8N_PASSWORD=$(openssl rand -base64 16)

# Crear archivo .env
log "Creando archivo de configuración..."
cat > .env << EOF
# Configuración de base de datos
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Configuración de n8n
N8N_USER=admin
N8N_PASSWORD=$N8N_PASSWORD
N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY

# Configuración de dominio (CAMBIAR POR TU DOMINIO)
DOMAIN_URL=https://tu-dominio.com

# Configuración de email (opcional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu-email@gmail.com
SMTP_PASS=tu-app-password
EOF

log "Archivo .env creado. IMPORTANTE: Edita .env con tu dominio real."

# Crear configuración de nginx
log "Creando configuración de nginx..."
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream n8n {
        server n8n:5678;
    }

    server {
        listen 80;
        server_name _;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location / {
            return 301 https://$host$request_uri;
        }
    }

    server {
        listen 443 ssl;
        server_name _;
        
        ssl_certificate /etc/letsencrypt/live/tu-dominio.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/tu-dominio.com/privkey.pem;
        
        location / {
            proxy_pass http://n8n;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
    }
}
EOF

# Crear script de backup
log "Creando script de backup..."
cat > scripts/backup.sh << 'EOF'
#!/bin/bash
# Script de backup para n8n

BACKUP_DIR="/home/$(whoami)/n8n-server/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup de PostgreSQL
docker exec n8n_postgres pg_dump -U n8n n8n > "$BACKUP_DIR/n8n_db_$DATE.sql"

# Backup de workflows y credenciales
docker exec n8n_app tar czf - /home/node/.n8n > "$BACKUP_DIR/n8n_data_$DATE.tar.gz"

# Limpiar backups antiguos (mantener últimos 7 días)
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Backup completado: $DATE"
EOF

chmod +x scripts/backup.sh

# Crear script de inicio
log "Creando script de inicio..."
cat > scripts/start.sh << 'EOF'
#!/bin/bash
cd /home/$(whoami)/n8n-server
docker-compose up -d
echo "n8n iniciado. Accede a https://tu-dominio.com"
echo "Usuario: admin"
echo "Contraseña: $(grep N8N_PASSWORD .env | cut -d'=' -f2)"
EOF

chmod +x scripts/start.sh

# Crear script de parada
cat > scripts/stop.sh << 'EOF'
#!/bin/bash
cd /home/$(whoami)/n8n-server
docker-compose down
echo "n8n detenido."
EOF

chmod +x scripts/stop.sh

# Configurar cron para backups automáticos
log "Configurando backup automático diario..."
(crontab -l 2>/dev/null; echo "0 2 * * * /home/$(whoami)/n8n-server/scripts/backup.sh") | crontab -

echo "=================================================="
log "🎉 Instalación completada!"
echo ""
warn "PASOS SIGUIENTES:"
echo "1. Edita el archivo .env con tu dominio real"
echo "2. Configura tu dominio para apuntar a esta IP"
echo "3. Ejecuta: cd $PROJECT_DIR && ./scripts/start.sh"
echo "4. Configura SSL: docker-compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot -d tu-dominio.com"
echo ""
log "Credenciales por defecto:"
echo "Usuario: admin"
echo "Contraseña: $N8N_PASSWORD"
echo ""
warn "⚠️  Guarda estas credenciales en un lugar seguro!"