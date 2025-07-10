#!/bin/bash

# 🚀 Instalador MAXIMIZADO para Oracle Cloud ARM - n8n Automation Powerhouse
# Optimizado para VM.Standard.A1.Flex con 4 OCPUs y 24GB RAM

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging con timestamp
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Banner
cat << 'EOF'
 ███▄    █   █████▄     ███▄    █     
 ██ ▀█   █  ██▄▄▄▄██    ██ ▀█   █     
▐██  ▀█▄ █ ▐██▀▀▀▀▀▀   ▐██  ▀█▄ █     
▐██▌   ███ ▐██          ▐██▌   ███     
 ██▌   ▐██  ███████████  ██▌   ▐██     
 ▀▀▀   ▀▀▀   ▀▀▀▀▀▀▀▀▀   ▀▀▀   ▀▀▀     

🚀 Oracle Cloud ARM MAXIMIZED Setup
📊 Utilizando 4 OCPUs + 24GB RAM
🔥 Configuración de alta disponibilidad
EOF

echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  n8n Automation Powerhouse - Oracle Cloud Free Tier${NC}"
echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"

# Verificar si se ejecuta como root
if [[ $EUID -eq 0 ]]; then
    error "No ejecutes este script como root. Usa tu usuario normal con sudo."
    exit 1
fi

# Función para verificar recursos del sistema
check_system_resources() {
    log "🔍 Verificando recursos del sistema..."
    
    # CPU cores
    CPU_CORES=$(nproc)
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    DISK_GB=$(df -BG / | tail -1 | awk '{print $2}' | sed 's/G//')
    
    echo "┌─────────────────────────────────────┐"
    echo "│         RECURSOS DETECTADOS         │"
    echo "├─────────────────────────────────────┤"
    echo "│ CPUs: ${CPU_CORES} cores                    │"
    echo "│ RAM:  ${RAM_GB}GB                         │" 
    echo "│ Disk: ${DISK_GB}GB                        │"
    echo "└─────────────────────────────────────┘"
    
    # Verificaciones
    if [ "$CPU_CORES" -lt 2 ]; then
        warning "Se detectaron menos de 2 CPU cores. El rendimiento puede ser limitado."
    fi
    
    if [ "$RAM_GB" -lt 8 ]; then
        warning "Se detectaron menos de 8GB RAM. Ajustando configuración..."
        export MEMORY_OPTIMIZED=true
    fi
    
    if [ "$CPU_CORES" -ge 4 ] && [ "$RAM_GB" -ge 20 ]; then
        success "🔥 Configuración ARM MAXIMIZADA detectada! Usando configuración de alta performance."
        export HIGH_PERFORMANCE=true
    fi
}

# Función para instalar Docker optimizado para ARM
install_docker() {
    log "🐳 Instalando Docker optimizado para ARM..."
    
    # Remover versiones anteriores
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Actualizar sistema
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common
    
    # Agregar repositorio oficial de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Instalar Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    
    # Configurar Docker daemon para ARM optimización
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ],
    "experimental": false,
    "metrics-addr": "127.0.0.1:9323",
    "default-runtime": "runc",
    "runtimes": {
        "runc": {
            "path": "runc"
        }
    }
}
EOF
    
    # Reiniciar Docker
    sudo systemctl restart docker
    sudo systemctl enable docker
    
    success "Docker instalado y configurado para ARM"
}

# Función para configurar firewall
configure_firewall() {
    log "🔥 Configurando firewall..."
    
    # Instalar ufw si no está
    sudo apt-get install -y ufw
    
    # Resetear configuración
    sudo ufw --force reset
    
    # Reglas básicas
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # SSH (mantener conexión actual)
    sudo ufw allow ssh
    
    # HTTP/HTTPS
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    # n8n (temporal para configuración)
    sudo ufw allow 5678/tcp
    
    # Grafana
    sudo ufw allow 3000/tcp
    
    # PostgreSQL (solo local)
    sudo ufw allow from 172.20.0.0/16 to any port 5432
    
    # Redis (solo local)
    sudo ufw allow from 172.20.0.0/16 to any port 6379
    
    # Elasticsearch (solo local)
    sudo ufw allow from 172.20.0.0/16 to any port 9200
    
    # Activar firewall
    sudo ufw --force enable
    
    success "Firewall configurado"
}

# Función para optimizar sistema para ARM
optimize_system() {
    log "⚡ Optimizando sistema para ARM y alta carga..."
    
    # Límites del sistema
    sudo tee -a /etc/security/limits.conf > /dev/null <<EOF
# n8n optimizations
* soft nofile 65535
* hard nofile 65535
* soft nproc 32768
* hard nproc 32768
EOF
    
    # Parámetros del kernel
    sudo tee -a /etc/sysctl.conf > /dev/null <<EOF
# Network optimizations
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 3

# Memory optimizations
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.max_map_count = 262144

# File system optimizations
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
EOF
    
    # Aplicar cambios
    sudo sysctl -p
    
    # Configurar swap (solo si es necesario)
    if [ "$RAM_GB" -lt 16 ]; then
        log "Configurando swap de 4GB..."
        sudo fallocate -l 4G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    fi
    
    success "Sistema optimizado para ARM"
}

# Función para crear estructura de directorios
create_directory_structure() {
    log "📁 Creando estructura de directorios..."
    
    # Directorio principal
    PROJECT_DIR="$HOME/n8n-powerhouse"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # Crear directorios necesarios
    mkdir -p {nginx/{ssl,conf.d},postgres,scripts,backups,monitoring,logs}
    mkdir -p {data/{n8n_primary,n8n_secondary,postgres,redis,grafana,prometheus,elasticsearch}}
    
    # Establecer permisos
    chmod 755 "$PROJECT_DIR"
    sudo chown -R $USER:$USER "$PROJECT_DIR"
    
    export PROJECT_DIR
    success "Estructura de directorios creada en $PROJECT_DIR"
}

# Función para generar configuración de entorno
generate_env_config() {
    log "⚙️  Generando configuración de entorno..."
    
    # Generar contraseñas seguras
    N8N_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    GRAFANA_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    
    # Detectar IP pública
    PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || echo "localhost")
    
    # Crear archivo .env
    cat > .env <<EOF
# === CONFIGURACIÓN GENERAL ===
COMPOSE_PROJECT_NAME=n8n-powerhouse
TIMEZONE=Europe/Madrid

# === NETWORKING ===
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
PUBLIC_IP=$PUBLIC_IP
DOMAIN_URL=https://$PUBLIC_IP
WEBHOOK_URL=https://$PUBLIC_IP

# === N8N CONFIGURATION ===
N8N_USER=admin
N8N_PASSWORD=$N8N_PASSWORD
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

# === DATABASE ===
POSTGRES_DB=n8n_powerhouse
POSTGRES_USER=n8n_admin
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# === MONITORING ===
GRAFANA_PASSWORD=$GRAFANA_PASSWORD

# === PERFORMANCE SETTINGS ===
HIGH_PERFORMANCE=${HIGH_PERFORMANCE:-false}
MEMORY_OPTIMIZED=${MEMORY_OPTIMIZED:-false}
EOF
    
    # Mostrar credenciales
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│                  CREDENCIALES GENERADAS                │"
    echo "├─────────────────────────────────────────────────────────┤"
    echo "│ n8n URL:      https://$PUBLIC_IP                │"
    echo "│ n8n User:     admin                                     │"
    echo "│ n8n Pass:     $N8N_PASSWORD      │"
    echo "│                                                         │"
    echo "│ Grafana URL:  https://$PUBLIC_IP:3000           │"
    echo "│ Grafana Pass: $GRAFANA_PASSWORD      │"
    echo "│                                                         │"
    echo "│ PostgreSQL Pass: $POSTGRES_PASSWORD   │"
    echo "└─────────────────────────────────────────────────────────┘"
    
    # Guardar credenciales en archivo
    cat > credentials.txt <<EOF
n8n Automation Powerhouse - Credenciales
========================================

Acceso Web:
- URL: https://$PUBLIC_IP
- Usuario: admin
- Contraseña: $N8N_PASSWORD

Monitoring (Grafana):
- URL: https://$PUBLIC_IP:3000
- Contraseña: $GRAFANA_PASSWORD

Base de Datos:
- Host: postgres (interno)
- Database: n8n_powerhouse
- Usuario: n8n_admin
- Contraseña: $POSTGRES_PASSWORD

IP Pública: $PUBLIC_IP
Fecha instalación: $(date)
EOF
    
    chmod 600 credentials.txt
    success "Configuración de entorno generada"
}

# Función para generar certificados SSL
generate_ssl_certificates() {
    log "🔒 Generando certificados SSL..."
    
    mkdir -p nginx/ssl
    
    # Generar certificado autofirmado
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout nginx/ssl/nginx-selfsigned.key \
        -out nginx/ssl/nginx-selfsigned.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=n8n-powerhouse/CN=$PUBLIC_IP" \
        -addext "subjectAltName=IP:$PUBLIC_IP,DNS:localhost"
    
    # Generar parámetros DH para mayor seguridad
    openssl dhparam -out nginx/ssl/dhparam.pem 2048
    
    # Establecer permisos seguros
    chmod 600 nginx/ssl/*
    
    success "Certificados SSL generados"
}

# Función para crear configuración de PostgreSQL optimizada
create_postgres_config() {
    log "🐘 Configurando PostgreSQL para alta performance..."
    
    mkdir -p postgres
    
    # Configuración optimizada para ARM con mucha RAM
    cat > postgres/postgresql.conf <<EOF
# PostgreSQL Configuration optimized for ARM + 24GB RAM

# CONNECTIONS AND AUTHENTICATION
max_connections = 200
superuser_reserved_connections = 3

# MEMORY SETTINGS
shared_buffers = 6GB                    # 25% of total RAM
effective_cache_size = 18GB             # 75% of total RAM
work_mem = 256MB                        # For complex queries
maintenance_work_mem = 2GB              # For VACUUM, CREATE INDEX
dynamic_shared_memory_type = posix

# CHECKPOINT SETTINGS
checkpoint_completion_target = 0.9
wal_buffers = 64MB
checkpoint_timeout = 15min
max_wal_size = 4GB
min_wal_size = 1GB

# QUERY PLANNER
random_page_cost = 1.1                  # SSD optimization
effective_io_concurrency = 200          # For SSD
seq_page_cost = 1.0

# LOGGING
log_destination = 'stderr'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_min_error_statement = error
log_min_duration_statement = 1000      # Log slow queries

# ARM SPECIFIC OPTIMIZATIONS
cpu_tuple_cost = 0.01
cpu_index_tuple_cost = 0.005
cpu_operator_cost = 0.0025

# BACKGROUND WRITER
bgwriter_delay = 200ms
bgwriter_lru_maxpages = 100
bgwriter_lru_multiplier = 2.0

# AUTOVACUUM
autovacuum_max_workers = 4
autovacuum_naptime = 30s
EOF
    
    success "Configuración PostgreSQL creada"
}

# Función para crear scripts de gestión
create_management_scripts() {
    log "📜 Creando scripts de gestión..."
    
    # Script de inicio
    cat > scripts/start.sh <<'EOF'
#!/bin/bash
echo "🚀 Iniciando n8n Powerhouse..."
docker-compose -f docker-compose-maximized.yml up -d
echo "✅ Servicios iniciados"
docker-compose -f docker-compose-maximized.yml ps
EOF
    
    # Script de parada
    cat > scripts/stop.sh <<'EOF'
#!/bin/bash
echo "⏹️  Deteniendo n8n Powerhouse..."
docker-compose -f docker-compose-maximized.yml down
echo "✅ Servicios detenidos"
EOF
    
    # Script de backup
    cat > scripts/backup.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/home/$(whoami)/n8n-powerhouse/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "📦 Iniciando backup completo..."

# Backup de PostgreSQL
docker-compose -f docker-compose-maximized.yml exec -T postgres pg_dump -U n8n_admin n8n_powerhouse > "$BACKUP_DIR/postgres_$DATE.sql"

# Backup de volúmenes n8n
docker run --rm -v n8n-powerhouse_n8n_data_primary:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/n8n_primary_$DATE.tar.gz -C /data .
docker run --rm -v n8n-powerhouse_n8n_data_secondary:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/n8n_secondary_$DATE.tar.gz -C /data .

# Backup de configuración
tar czf "$BACKUP_DIR/config_$DATE.tar.gz" .env nginx/ monitoring/ scripts/

# Limpiar backups antiguos (mantener últimos 7 días)
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "✅ Backup completado: $DATE"
EOF
    
    # Script de monitoreo
    cat > scripts/monitor.sh <<'EOF'
#!/bin/bash
echo "📊 Estado del sistema n8n Powerhouse"
echo "=================================="

# Estado de contenedores
echo "🐳 Contenedores:"
docker-compose -f docker-compose-maximized.yml ps

echo ""
echo "💾 Uso de recursos:"
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "RAM: $(free -h | grep Mem | awk '{print "Usado: " $3 " / Total: " $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print "Usado: " $3 " / Total: " $2 " (" $5 ")"}')"

echo ""
echo "🌐 Conexiones de red:"
ss -tuln | grep -E "(5678|3000|5432|6379)"

echo ""
echo "📈 Logs recientes n8n:"
docker-compose -f docker-compose-maximized.yml logs --tail=5 n8n-primary
EOF
    
    # Script de actualización
    cat > scripts/update.sh <<'EOF'
#!/bin/bash
echo "🔄 Actualizando n8n Powerhouse..."

# Backup antes de actualizar
./scripts/backup.sh

# Actualizar imágenes
docker-compose -f docker-compose-maximized.yml pull

# Recrear contenedores
docker-compose -f docker-compose-maximized.yml up -d --force-recreate

echo "✅ Actualización completada"
EOF
    
    # Hacer ejecutables
    chmod +x scripts/*.sh
    
    success "Scripts de gestión creados"
}

# Función para descargar archivos de configuración del repositorio
download_config_files() {
    log "⬇️  Descargando archivos de configuración..."
    
    # URL base del repositorio
    REPO_URL="https://raw.githubusercontent.com/aroca89/n8n-oracle-cloud/main"
    
    # Descargar docker-compose maximizado
    curl -fsSL "$REPO_URL/docker-compose-maximized.yml" -o docker-compose-maximized.yml
    
    # Descargar configuración nginx
    curl -fsSL "$REPO_URL/nginx/nginx-maximized.conf" -o nginx/nginx.conf
    
    # Verificar descargas
    if [[ ! -f "docker-compose-maximized.yml" ]]; then
        error "Error descargando docker-compose-maximized.yml"
        exit 1
    fi
    
    success "Archivos de configuración descargados"
}

# Función para inicializar servicios
initialize_services() {
    log "🚀 Inicializando servicios..."
    
    # Crear red Docker si no existe
    docker network create n8n-network 2>/dev/null || true
    
    # Iniciar servicios
    docker-compose -f docker-compose-maximized.yml up -d
    
    # Esperar a que los servicios estén listos
    log "⏳ Esperando a que los servicios estén listos..."
    sleep 30
    
    # Verificar estado
    docker-compose -f docker-compose-maximized.yml ps
    
    success "Servicios inicializados"
}

# Función para mostrar resumen final
show_final_summary() {
    echo ""
    echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
    echo "🎉                                              🎉"
    echo "🎉        ¡INSTALACIÓN COMPLETADA!             🎉"
    echo "🎉    n8n Powerhouse está funcionando          🎉"
    echo "🎉                                              🎉"
    echo "🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉"
    echo ""
    echo "📋 INFORMACIÓN DE ACCESO:"
    echo "────────────────────────────────────────"
    echo "🌐 n8n Interface: https://$PUBLIC_IP"
    echo "📊 Grafana Monitoring: https://$PUBLIC_IP:3000"
    echo "📁 Directorio del proyecto: $PROJECT_DIR"
    echo "🔑 Credenciales guardadas en: $PROJECT_DIR/credentials.txt"
    echo ""
    echo "🛠️  COMANDOS ÚTILES:"
    echo "────────────────────────────────────────"
    echo "📁 cd $PROJECT_DIR"
    echo "🚀 ./scripts/start.sh      # Iniciar servicios"
    echo "⏹️  ./scripts/stop.sh       # Detener servicios"
    echo "📦 ./scripts/backup.sh     # Crear backup"
    echo "📊 ./scripts/monitor.sh    # Ver estado"
    echo "🔄 ./scripts/update.sh     # Actualizar"
    echo ""
    echo "⚡ RECURSOS UTILIZADOS:"
    echo "────────────────────────────────────────"
    echo "🖥️  CPU Cores: $CPU_CORES"
    echo "💾 RAM Total: ${RAM_GB}GB"
    echo "💿 Almacenamiento: ${DISK_GB}GB"
    echo ""
    echo "🔧 PRÓXIMOS PASOS:"
    echo "────────────────────────────────────────"
    echo "1. Abrir https://$PUBLIC_IP en tu navegador"
    echo "2. Iniciar sesión con las credenciales generadas"
    echo "3. Crear tu primer workflow de automatización"
    echo "4. (Opcional) Configurar dominio personalizado"
    echo ""
    warning "IMPORTANTE: Guarda el archivo credentials.txt en un lugar seguro"
}

# Función principal de instalación
main() {
    log "Iniciando instalación de n8n Powerhouse..."
    
    check_system_resources
    install_docker
    configure_firewall
    optimize_system
    create_directory_structure
    generate_env_config
    generate_ssl_certificates
    create_postgres_config
    create_management_scripts
    download_config_files
    initialize_services
    show_final_summary
    
    # Recargar sesión para aplicar cambios de grupo docker
    warning "Reinicia tu sesión SSH o ejecuta: newgrp docker"
    warning "Luego puedes gestionar los servicios con los scripts en $PROJECT_DIR/scripts/"
}

# Manejo de errores
trap 'error "La instalación falló en la línea $LINENO"' ERR

# Ejecutar instalación
main "$@"