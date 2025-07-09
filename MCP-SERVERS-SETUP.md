# 🛠️ Configuración de MCP Servers - Cloudflare y Oracle Cloud

Guía completa para configurar los servidores MCP de Cloudflare y Oracle Cloud para gestionar tu infraestructura desde Claude.

## 🌐 Servidor MCP de Cloudflare (Oficial)

### **Paso 1: Instalar servidor oficial**
```bash
npm install -g @cloudflare/mcp-server-cloudflare
```

### **Paso 2: Obtener token de Cloudflare**
1. Ve a [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click **"Create Token"**
3. Usar template **"Custom token"**
4. **Permisos necesarios:**
   ```
   Zone:Zone:Read
   Zone:DNS:Edit
   Zone:Zone Settings:Edit
   Account:Workers Scripts:Edit
   Account:Workers KV Storage:Edit
   Account:Page Rules:Edit
   Account:Cloudflare Tunnel:Edit
   ```

### **Paso 3: Configurar en Claude Desktop**
```json
{
  "mcpServers": {
    "cloudflare": {
      "command": "npx",
      "args": ["@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "tu-token-cloudflare-aqui"
      }
    }
  }
}
```

### **Capacidades del servidor Cloudflare:**
- ✅ **Gestión de DNS** - Crear, editar, eliminar records
- ✅ **Cloudflare Workers** - Deploy y gestión de funciones
- ✅ **Cloudflare KV** - Almacenamiento clave-valor
- ✅ **Configuración de SSL** - Certificados y modos de encriptación
- ✅ **Page Rules** - Reglas de caché y redirección
- ✅ **Firewall Rules** - Configuración de seguridad
- ✅ **Analytics** - Métricas de tráfico y rendimiento

---

## ☁️ Servidor MCP de Oracle Cloud (Personalizado)

### **Paso 1: Instalar dependencias**
```bash
# Clonar el repositorio
git clone https://github.com/aroca89/n8n-oracle-cloud.git
cd n8n-oracle-cloud/mcp-servers

# Instalar dependencias
npm install
```

### **Paso 2: Configurar OCI CLI**
```bash
# Instalar OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Configurar credenciales
oci setup config
```

**Durante la configuración necesitarás:**
- **User OCID** - de tu perfil Oracle Cloud
- **Tenancy OCID** - de tu cuenta Oracle Cloud
- **Region** - donde están tus recursos
- **Private key path** - ruta a tu clave privada

### **Paso 3: Hacer ejecutable el servidor**
```bash
chmod +x oracle-cloud-server.js
```

### **Paso 4: Configurar en Claude Desktop**
```json
{
  "mcpServers": {
    "oracle-cloud": {
      "command": "node",
      "args": ["/ruta/completa/a/n8n-oracle-cloud/mcp-servers/oracle-cloud-server.js"],
      "env": {
        "OCI_CONFIG_FILE": "~/.oci/config",
        "OCI_CONFIG_PROFILE": "DEFAULT"
      }
    }
  }
}
```

### **Capacidades del servidor Oracle Cloud:**
- ✅ **Gestión de instancias** - Listar, crear, iniciar, detener
- ✅ **Información detallada** - Estado, configuración, métricas
- ✅ **Gestión de VCNs** - Redes virtuales y subredes
- ✅ **Automatización n8n** - Setup optimizado para n8n
- ✅ **Configuración de seguridad** - Security lists y reglas
- ✅ **Monitoreo** - Estado de recursos y alerts

---

## 🔧 Configuración Completa de Ambos Servidores

### **Archivo de configuración final:**
```bash
cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "/Users/arocapzos"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-sequential-thinking"]
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "TU_TOKEN_GITHUB"
      }
    },
    "cloudflare": {
      "command": "npx",
      "args": ["@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "TU_TOKEN_CLOUDFLARE"
      }
    },
    "oracle-cloud": {
      "command": "node",
      "args": ["/Users/arocapzos/n8n-oracle-cloud/mcp-servers/oracle-cloud-server.js"],
      "env": {
        "OCI_CONFIG_FILE": "~/.oci/config",
        "OCI_CONFIG_PROFILE": "DEFAULT"
      }
    }
  }
}
EOF
```

---

## 🚀 Casos de uso prácticos

### **Con Cloudflare MCP:**
```
"Configura un record DNS A para n8n.midominio.com apuntando a 150.230.x.x"
"Activa el SSL modo Full Strict para mi dominio"
"Crea una regla de firewall para bloquear tráfico de China excepto Hong Kong"
"Despliega un Worker para redireccionar www a dominio principal"
```

### **Con Oracle Cloud MCP:**
```
"Lista todas mis instancias en Oracle Cloud"
"Crea una nueva instancia optimizada para n8n con Ubuntu 22.04"
"Inicia la instancia llamada 'n8n-server' que está detenida"
"Muéstrame los detalles de la instancia ocid1.instance.oc1..."
```

### **Combinando ambos:**
```
"Crea una instancia en Oracle Cloud y configura el DNS en Cloudflare automáticamente"
"Lista mis instancias Oracle y configura un Worker de Cloudflare para cada una"
"Configura un túnel Cloudflare para acceso seguro a mi instancia n8n"
```

---

## 🔍 Verificación y troubleshooting

### **Verificar instalación:**
```bash
# Verificar Cloudflare MCP
npx @cloudflare/mcp-server-cloudflare --help

# Verificar Oracle Cloud CLI
oci --version

# Verificar nuestro servidor personalizado
cd mcp-servers && node oracle-cloud-server.js
```

### **Logs de debug:**
```bash
# Ver logs de Claude Desktop
tail -f ~/Library/Logs/Claude/claude_desktop.log

# Verificar configuración MCP
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### **Problemas comunes:**

1. **Error de autenticación Cloudflare:**
   - Verificar token y permisos
   - Regenerar token si es necesario

2. **Error OCI CLI:**
   ```bash
   # Reconfigurar OCI
   oci setup config --overwrite
   ```

3. **Servidor no se conecta:**
   - Verificar rutas absolutas en configuración
   - Comprobar permisos de ejecución

---

## 📈 Próximos pasos

### **Funcionalidades avanzadas a implementar:**
- **Auto-scaling** de instancias Oracle Cloud
- **Deployment automático** de Workers desde Claude
- **Monitoreo integrado** con alertas
- **Backup automático** de configuraciones
- **Multi-region management** Oracle Cloud

### **Integración con n8n:**
- **Webhook automático** desde Oracle a Cloudflare
- **DNS dinámico** basado en estado de instancias
- **Load balancing** inteligente con Workers

---

**¡Ahora puedes gestionar toda tu infraestructura cloud directamente desde Claude! 🎉**