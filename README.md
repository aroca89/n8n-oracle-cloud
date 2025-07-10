# 🚀 n8n Oracle Cloud Powerhouse - Automatizaciones Privadas

Sistema completo de automatizaciones con n8n optimizado para Oracle Cloud Always Free, aprovechando al MÁXIMO los recursos disponibles.

## 🔥 **CONFIGURACIÓN MAXIMIZADA DISPONIBLE**

### **Oracle Cloud Free Tier - Recursos Completos:**
- **🖥️ ARM Ampere A1:** Hasta 4 OCPUs + 24GB RAM (GRATIS para siempre)
- **💾 Almacenamiento:** 200GB Block Storage total
- **🌐 Red:** 10TB transferencia saliente/mes
- **⚡ Rendimiento:** Superior a servidores de $200/mes

---

## ⚡ **INSTALACIÓN RÁPIDA - CONFIGURACIÓN MAXIMIZADA**

### **Paso 1: Crear instancia ARM MAXIMIZADA en Oracle Cloud**

1. **Oracle Cloud Console** → **Compute** → **Instances** → **Create Instance**

2. **Configuración ÓPTIMA:**
   ```
   Name: n8n-automation-powerhouse
   Image: Ubuntu 22.04 LTS (ARM64)
   Shape: VM.Standard.A1.Flex
   OCPUs: 4 (MÁXIMO)
   Memory: 24 GB (MÁXIMO)
   Boot Volume: 100 GB
   Network: Assign public IPv4 address
   ```

3. **Security List:** Permitir puertos 80, 443, 5678, 3000

### **Paso 2: Instalación automática**

```bash
# Conectar al servidor
ssh -i tu-clave.key ubuntu@TU-IP-PUBLICA

# Instalación MAXIMIZADA con un comando
curl -fsSL https://raw.githubusercontent.com/aroca89/n8n-oracle-cloud/main/install-maximized.sh | bash
```

**¡Eso es todo!** En 10-15 minutos tendrás:
- ✅ **2 instancias n8n** con load balancing
- ✅ **PostgreSQL** optimizado para ARM
- ✅ **Redis** para colas y cache
- ✅ **Nginx** con SSL y rate limiting
- ✅ **Grafana + Prometheus** para monitoreo
- ✅ **Backups automáticos**

---

## 🏗️ **Arquitectura del Sistema**

```
┌─────────────────────────────────────────────────────────────┐
│                    ORACLE CLOUD ARM A1                     │
│                   4 OCPUs + 24GB RAM                       │
├─────────────────────────────────────────────────────────────┤
│  Internet → Cloudflare → Nginx Load Balancer               │
│                           ↓                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   n8n-1     │ │   n8n-2     │ │ PostgreSQL  │          │
│  │  (8GB RAM)  │ │  (8GB RAM)  │ │  (6GB RAM)  │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
│                           ↓                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Redis     │ │  Backups    │ │  Monitoring │          │
│  │  (1GB RAM)  │ │ Auto-daily  │ │   Grafana   │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ **Características del Sistema**

### **🚀 Rendimiento:**
- **Alta disponibilidad** con 2 instancias n8n
- **Load balancing** inteligente con Nginx
- **Queue system** con Redis para procesos pesados
- **Cache** optimizado para ARM
- **Base de datos** PostgreSQL con 6GB buffer

### **🔒 Seguridad:**
- **SSL/TLS** automático
- **Rate limiting** configurable
- **Firewall** optimizado
- **Autenticación** robusta
- **Backup** cifrado automático

### **📊 Monitoreo:**
- **Grafana** con dashboards pre-configurados
- **Prometheus** para métricas
- **Logs** centralizados
- **Alertas** automáticas
- **Métricas** de rendimiento en tiempo real

---

## 📱 **Acceso al Sistema**

Después de la instalación:

```bash
🌐 n8n Interface: https://TU-IP-PUBLICA
📊 Grafana Monitor: https://TU-IP-PUBLICA:3000
🔑 Credenciales: ~/n8n-powerhouse/credentials.txt
```

---

## 🛠️ **Gestión del Sistema**

### **Comandos principales:**
```bash
cd ~/n8n-powerhouse

# Gestión de servicios
./scripts/start.sh      # Iniciar todo
./scripts/stop.sh       # Detener todo
./scripts/restart.sh    # Reiniciar todo

# Mantenimiento
./scripts/backup.sh     # Backup manual
./scripts/update.sh     # Actualizar sistema
./scripts/monitor.sh    # Ver estado actual

# Logs
./scripts/logs.sh       # Ver logs en tiempo real
```

### **Archivos de configuración:**
```bash
.env                           # Variables principales
docker-compose-maximized.yml   # Orquestación de servicios
nginx/nginx-maximized.conf     # Load balancer
monitoring/                    # Configuración Grafana/Prometheus
```

---

## 🔧 **Configuraciones Disponibles**

| Configuración | Uso | Recursos |
|---------------|-----|----------|
| **Maximizada** | ARM 4 OCPUs + 24GB | Alta disponibilidad + Monitoreo |
| **Estándar** | ARM 2 OCPUs + 12GB | n8n + PostgreSQL + Nginx |
| **Básica** | x86 1 OCPU + 1GB | Solo n8n con SQLite |
| **Cloudflare** | Cualquiera + Dominio | Optimizado para CF proxy |

---

## 📊 **Comparación de Rendimiento**

| Métrica | Oracle Free (ARM) | Servidor $200/mes |
|---------|-------------------|-------------------|
| **CPU Cores** | 4 ARM Cores | 2-4 x86 Cores |
| **RAM** | 24GB | 8-16GB |
| **Storage** | 200GB SSD | 50-100GB SSD |
| **Network** | 10TB/mes | 1-5TB/mes |
| **Costo** | **$0/mes** | $200/mes |
| **Rendimiento n8n** | **Superior** | Comparable |

---

## 🌟 **Casos de Uso Perfectos**

### **📈 Para Empresas:**
- **Automatizaciones** CRM y ventas
- **Integraciones** API múltiples
- **Pipelines** de datos
- **Notificaciones** automatizadas
- **Reportes** automáticos

### **🛠️ Para Desarrolladores:**
- **CI/CD** workflows
- **APIs** de integración
- **Microservicios** orquestación
- **Data processing** pipelines
- **IoT** data collection

### **🏠 Para Uso Personal:**
- **Smart home** automation
- **Social media** management
- **Backup** automático
- **Monitoring** personal
- **Task** automation

---

## 📋 **Instalaciones Especializadas**

### **🌐 Con Dominio Personalizado (Cloudflare):**
```bash
# Usar configuración optimizada para Cloudflare
curl -fsSL https://raw.githubusercontent.com/aroca89/n8n-oracle-cloud/main/install-cloudflare.sh | bash
```

### **🔧 Solo n8n Básico:**
```bash
# Instalación mínima
curl -fsSL https://raw.githubusercontent.com/aroca89/n8n-oracle-cloud/main/install.sh | bash
```

### **🚀 Configuración Manual:**
```bash
git clone https://github.com/aroca89/n8n-oracle-cloud.git
cd n8n-oracle-cloud
cp .env.maximized .env
# Editar .env con tus configuraciones
docker-compose -f docker-compose-maximized.yml up -d
```

---

## 📚 **Documentación Adicional**

- **[🚀 Configuración Maximizada](ORACLE-MAXIMIZED-SETUP.md)** - Guía completa ARM
- **[🌐 Setup con Cloudflare](CLOUDFLARE-SETUP.md)** - Dominio personalizado
- **[📊 Monitoreo Avanzado](MONITORING-SETUP.md)** - Grafana y alertas
- **[🔒 Configuración de Seguridad](SECURITY-SETUP.md)** - Hardening del sistema
- **[🔄 Backup y Restauración](BACKUP-RESTORE.md)** - Gestión de datos

---

## 🆘 **Soporte y Troubleshooting**

### **Problemas comunes:**

1. **Error de memoria:**
   ```bash
   # Verificar recursos
   ./scripts/monitor.sh
   # Optimizar para menos RAM
   cp .env.memory-optimized .env
   ```

2. **SSL no funciona:**
   ```bash
   # Regenerar certificados
   ./scripts/regenerate-ssl.sh
   ```

3. **n8n no responde:**
   ```bash
   # Ver logs
   ./scripts/logs.sh n8n-primary
   # Reiniciar servicios
   ./scripts/restart.sh
   ```

### **Logs importantes:**
```bash
# Logs en tiempo real
docker-compose -f docker-compose-maximized.yml logs -f

# Logs específicos
docker-compose logs n8n-primary
docker-compose logs nginx
docker-compose logs postgres
```

---

## 📈 **Métricas y Rendimiento**

Después de la instalación podrás ver:

- **⚡ Throughput:** Hasta 1000+ workflows/hora
- **🔄 Concurrencia:** 50+ workflows simultáneos
- **📊 Latencia:** <100ms response time
- **💾 Storage:** Compresión automática
- **🌐 Network:** Rate limiting inteligente

---

## 🎯 **¿Por qué esta configuración?**

✅ **Gratis para siempre** con Oracle Cloud Always Free  
✅ **Rendimiento superior** a VPS de pago  
✅ **Alta disponibilidad** con múltiples instancias  
✅ **Escalabilidad** automática  
✅ **Seguridad** de nivel empresarial  
✅ **Monitoreo** completo incluido  
✅ **Backup** automático diario  
✅ **Soporte** para miles de integraciones  

---

## 🚀 **¡Empieza Ahora!**

1. **Crea** tu cuenta Oracle Cloud (gratis)
2. **Ejecuta** el comando de instalación
3. **Accede** a tu n8n en minutos
4. **Automatiza** todo lo que imagines

**¡Disfruta de automatizaciones ilimitadas sin pagar un euro! 🎉**

---

## 📄 **Licencia**

Este proyecto es para uso personal y automatizaciones privadas. Oracle Cloud Free Tier es gratis para siempre según sus términos de servicio.