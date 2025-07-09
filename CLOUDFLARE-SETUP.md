# 🌐 Configuración de Cloudflare para n8n

Guía paso a paso para configurar tu dominio de Cloudflare con n8n en Oracle Cloud.

## 🎯 Ventajas de usar Cloudflare

- ✅ **SSL gratuito** - No necesitas configurar Let's Encrypt
- ✅ **Protección DDoS** automática
- ✅ **CDN global** - Mejor rendimiento mundial
- ✅ **Firewall WAF** - Protección contra ataques
- ✅ **Analytics** detallados de tráfico

## 📋 Pasos de configuración

### 1. Configurar DNS en Cloudflare

En tu panel de Cloudflare:

1. **Agregar registro A:**
   ```
   Type: A
   Name: n8n (o el subdominio que prefieras)
   IPv4: TU-IP-DE-ORACLE-CLOUD
   Proxy status: 🟠 Proxied (naranja)
   TTL: Auto
   ```

2. **Opcional - Registro CNAME para www:**
   ```
   Type: CNAME
   Name: www
   Target: n8n.tu-dominio.com
   Proxy status: 🟠 Proxied (naranja)
   ```

### 2. Configurar SSL/TLS en Cloudflare

1. Ve a **SSL/TLS → Overview**
2. Selecciona **Full (strict)** como modo de encriptación
3. En **SSL/TLS → Edge Certificates**:
   - ✅ Always Use HTTPS: ON
   - ✅ HTTP Strict Transport Security (HSTS): ON
   - ✅ Minimum TLS Version: 1.2

### 3. Configurar Firewall (opcional pero recomendado)

1. Ve a **Security → WAF**
2. **Custom rules** - Crear regla para proteger n8n:
   ```
   Rule name: Protect n8n Admin
   Field: URI Path
   Operator: equals
   Value: /
   Action: JS Challenge (o Block para mayor seguridad)
   ```

### 4. Configurar Page Rules (opcional)

1. Ve a **Rules → Page Rules**
2. **Crear regla para cache:**
   ```
   URL: n8n.tu-dominio.com/assets/*
   Settings: Cache Level = Cache Everything
   ```

## 🚀 Instalación en Oracle Cloud con Cloudflare

### Paso 1: Conectar al servidor
```bash
ssh -i tu-clave.key ubuntu@tu-ip-publica
```

### Paso 2: Clonar repositorio
```bash
git clone https://github.com/aroca89/n8n-oracle-cloud.git
cd n8n-oracle-cloud
```

### Paso 3: Usar configuración para Cloudflare
```bash
# Usar docker-compose específico para Cloudflare
cp docker-compose-cloudflare.yml docker-compose.yml

# Crear estructura de directorios
mkdir -p {nginx,workflows,credentials,backups,scripts}

# Copiar configuración de nginx
cp nginx/nginx-cloudflare.conf nginx/nginx.conf
cp nginx/cloudflare-ips.conf nginx/
```

### Paso 4: Configurar variables de entorno
```bash
# Copiar plantilla
cp .env.example .env

# Editar configuración
nano .env
```

**Configurar:**
```env
# Tu dominio de Cloudflare
DOMAIN_URL=https://n8n.tu-dominio.com

# Generar passwords seguros
POSTGRES_PASSWORD=tu-password-super-seguro
N8N_PASSWORD=tu-password-n8n
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
```

### Paso 5: Crear certificados SSL autofirmados
```bash
# Crear directorio SSL
mkdir -p nginx/ssl

# Generar certificados autofirmados para comunicación interna
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/nginx-selfsigned.key \
  -out nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=n8n/CN=localhost"
```

### Paso 6: Iniciar servicios
```bash
# Iniciar con docker-compose
docker-compose up -d

# Verificar que funciona
docker-compose ps
```

## ✅ Verificación

### Comprobar que funciona:
1. **Acceder a tu dominio:** https://n8n.tu-dominio.com
2. **Verificar SSL:** El candado verde debe aparecer
3. **Login:** Usuario `admin` con la contraseña de tu `.env`

### Logs útiles:
```bash
# Ver logs de n8n
docker-compose logs -f n8n

# Ver logs de nginx
docker-compose logs -f nginx

# Ver logs del sistema
sudo journalctl -f
```

## 🔧 Configuración avanzada

### Rate Limiting en Cloudflare
```
Rules → Rate Limiting
Rule name: n8n Protection
Request rate: 30 requests per minute
Action: Block
```

### Bot Fight Mode
```
Security → Bots
Bot Fight Mode: ON
Super Bot Fight Mode: ON (si tienes plan Pro+)
```

### Analytics y monitoreo
```
Analytics → Web Analytics
Traffic → Requests, Bandwidth, etc.
```

## 🔒 Seguridad adicional

### 1. IP Access Rules
Permitir solo tu IP:
```bash
Security → Tools → IP Access Rules
IP: TU-IP-CASA
Action: Allow
Zone: This website
```

### 2. Cloudflare Access (plan Teams)
Para acceso con autenticación adicional:
```
Zero Trust → Access → Applications
Add application → Self-hosted
```

### 3. Firewall Rules
```bash
# Bloquear países específicos
(ip.geoip.country ne "ES" and ip.geoip.country ne "US") 

# Permitir solo horarios laborales
(cf.edge.server_port eq 443 and http.request.timestamp.hour lt 8)
```

## 🚨 Troubleshooting

### Error "Too many redirects"
1. Verificar SSL mode en Cloudflare: **Full (strict)**
2. Verificar que nginx escucha en puerto 443

### Error "502 Bad Gateway"
```bash
# Verificar que n8n está ejecutándose
docker-compose ps

# Restart servicios
docker-compose restart
```

### No se ven IPs reales
1. Verificar `cloudflare-ips.conf` está cargado
2. Comprobar logs: `docker-compose logs nginx`

## 📊 Monitoreo

### Métricas importantes:
- **Requests per minute**
- **Response time**
- **Error rate**
- **Bandwidth usage**

### Alertas recomendadas:
- **High CPU usage** en Oracle Cloud
- **High error rate** en Cloudflare
- **SSL certificate expiry** (aunque Cloudflare lo renueva automáticamente)

---

**¡Tu n8n está ahora protegido y optimizado con Cloudflare! 🎉**