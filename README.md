# 🚀 n8n Server en Oracle Cloud - Automatizaciones Privadas

Sistema completo de automatizaciones con n8n optimizado para Oracle Cloud Always Free.

## ✅ Características

- **n8n** - Herramienta de automatización visual
- **PostgreSQL** - Base de datos robusta
- **Nginx** - Proxy reverso con SSL
- **Backup automático** - Respaldos diarios
- **Seguridad** - Autenticación y encriptación
- **Oracle Cloud optimizado** - Configuración específica para OCI

## 🏗️ Arquitectura

```
Internet → Nginx (SSL) → n8n → PostgreSQL
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

3. **Dominio propio** (opcional pero recomendado)

## 🚀 Instalación automática

### Paso 1: Conectar a tu servidor Oracle Cloud
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

Editar:
```env
DOMAIN_URL=https://tu-dominio.com
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

### Backup de seguridad:
- Backups automáticos diarios a las 2:00 AM
- Retención: 7 días
- Ubicación: `~/n8n-server/backups/`

## 📱 Acceso

- **URL:** https://tu-dominio.com (o http://tu-ip:5678)
- **Usuario:** admin
- **Contraseña:** Ver archivo .env

---

**¡Disfruta automatizando tus procesos con n8n! 🎉**