# 🚀 n8n Server en Oracle Cloud - Automatizaciones Privadas

Sistema completo de automatizaciones con n8n optimizado para Oracle Cloud Always Free.

## ✅ Características

- **n8n** - Herramienta de automatización visual
- **PostgreSQL** - Base de datos robusta  
- **Nginx** - Proxy reverso con SSL
- **Backup automático** - Respaldos diarios
- **Seguridad** - Autenticación y encriptación
- **Oracle Cloud optimizado** - Configuración específica para OCI
- **🌐 Cloudflare ready** - Configuración optimizada para dominios Cloudflare

## 🏗️ Arquitectura

```
Internet → Cloudflare → Nginx → n8n → PostgreSQL
                           ↓
                    Backups automáticos
```

## 📋 Requisitos previos

### En Oracle Cloud:
1. **Instancia Always Free** (Ubuntu 20.04/22.04)
   - 1-4 OCPUs ARM Ampere
   - 6-24 GB RAM
   - 100 GB almacenamiento

2. **Configuración de red:**
   - Security List: Puertos 80, 443 abiertos
   - Public IP asignada

3. **Dominio propio** (recomendado: Cloudflare)

## 🌐 Instalación con Cloudflare (Recomendado)

### Paso 1: Configurar DNS en Cloudflare
```
Type: A
Name: n8n
IPv4: TU-IP-DE-ORACLE-CLOUD
Proxy: 🟠 Proxied
```

### Paso 2: Conectar al servidor Oracle Cloud
```bash
ssh -i tu-clave.key ubuntu@tu-ip-publica
```

### Paso 3: Instalación automática con Cloudflare
```bash
# Clonar repositorio
git clone https://github.com/aroca89/n8n-oracle-cloud.git
cd n8n-oracle-cloud

# Usar configuración optimizada para Cloudflare
cp docker-compose-cloudflare.yml docker-compose.yml
```

### Paso 4: Configurar el entorno
```bash
# Copiar plantilla de configuración
cp .env.example .env

# Editar con tu dominio
nano .env
```

Configurar:
```env
DOMAIN_URL=https://n8n.tu-dominio.com
N8N_PASSWORD=tu-password-seguro
```

### Paso 5: Ejecutar instalación
```bash
# Crear estructura necesaria
mkdir -p {nginx,workflows,credentials,backups,scripts}
cp nginx/nginx-cloudflare.conf nginx/nginx.conf
cp nginx/cloudflare-ips.conf nginx/

# Crear certificados SSL autofirmados
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/nginx-selfsigned.key \
  -out nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=n8n/CN=localhost"

# Iniciar servicios
docker-compose up -d
```

**📖 [Guía completa de Cloudflare](CLOUDFLARE-SETUP.md)**

---

## 🚀 Instalación tradicional (sin Cloudflare)

### Paso 1: Conectar al servidor Oracle Cloud
```bash
ssh -i tu-clave.key ubuntu@tu-ip-publica
```

### Paso 2: Descargar e instalar
```bash
curl -fsSL https://raw.githubusercontent.com/aroca89/n8n-oracle-cloud/main/install.sh | bash
```

### Paso 3: Configurar dominio
```bash
cd ~/n8n-server
nano .env
```

### Paso 4: Iniciar servicios
```bash
./scripts/start.sh
```

### Paso 5: Configurar SSL (si tienes dominio)
```bash
docker-compose run --rm certbot certonly --webroot \
  --webroot-path /var/www/certbot \
  -d tu-dominio.com
```

---

## 📊 Gestión del sistema

### Comandos útiles:

```bash
# Iniciar n8n
./scripts/start.sh

# Detener n8n
./scripts/stop.sh

# Ver logs
docker-compose logs -f n8n

# Backup manual
./scripts/backup.sh

# Ver estado de contenedores
docker-compose ps

# Actualizar n8n
docker-compose pull && docker-compose up -d
```

## 🔒 Seguridad

### Credenciales por defecto:
- **Usuario:** admin
- **Contraseña:** Generada automáticamente (ver .env)

### Con Cloudflare (recomendado):
- ✅ SSL/TLS automático
- ✅ Protección DDoS
- ✅ WAF (Web Application Firewall)
- ✅ Rate limiting
- ✅ Bot protection

## 📱 Acceso

- **Con Cloudflare:** https://n8n.tu-dominio.com
- **Sin Cloudflare:** https://tu-dominio.com (o http://tu-ip:5678)
- **Usuario:** admin
- **Contraseña:** Ver archivo .env

## 🔄 Configuraciones disponibles

| Archivo | Uso |
|---------|-----|
| `docker-compose.yml` | Configuración estándar con Let's Encrypt |
| `docker-compose-cloudflare.yml` | Configuración optimizada para Cloudflare |
| `nginx/nginx.conf` | Nginx estándar con SSL |
| `nginx/nginx-cloudflare.conf` | Nginx optimizado para Cloudflare |

## 🆘 Soporte y troubleshooting

### Logs importantes:
```bash
# Logs de n8n
docker-compose logs -f n8n

# Logs de nginx
docker-compose logs -f nginx

# Logs del sistema
sudo journalctl -f
```

### Problemas comunes:

1. **Error de conexión:**
   - Verificar DNS en Cloudflare
   - Comprobar firewall: `sudo ufw status`

2. **SSL no funciona:**
   - Con Cloudflare: Verificar SSL mode = "Full (strict)"
   - Sin Cloudflare: Regenerar certificados

3. **n8n no inicia:**
   - Ver logs: `docker-compose logs n8n`
   - Verificar .env: `cat .env`

## 📄 Documentación adicional

- **[🌐 Configuración de Cloudflare](CLOUDFLARE-SETUP.md)** - Guía completa para dominios Cloudflare
- **[📝 Variables de entorno](.env.example)** - Plantilla de configuración

## 📄 Licencia

Este proyecto es para uso personal y automatizaciones privadas.

---

**¡Disfruta automatizando tus procesos con n8n! 🎉**

### 🚀 ¿Por qué elegir esta configuración?

- **Gratis para siempre** con Oracle Cloud Always Free
- **Escalable** hasta 4 OCPUs y 24GB RAM
- **Seguro** con Cloudflare y autenticación
- **Profesional** con dominio propio y SSL
- **Confiable** con backups automáticos