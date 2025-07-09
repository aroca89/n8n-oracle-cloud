#!/bin/bash

# 🚀 Quick Setup Script - MCP Servers Enhanced
# Instala y configura todos los MCP servers automáticamente

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up Enhanced MCP Servers${NC}"
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

success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

# Verificar directorio
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

log "Detected project directory: $PROJECT_DIR"

# Paso 1: Instalar dependencias MCP básicas
log "Installing basic MCP servers..."
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-sequential-thinking

# Paso 2: Instalar servidor oficial de Cloudflare
log "Installing official Cloudflare MCP server..."
npm install -g @cloudflare/mcp-server-cloudflare

# Paso 3: Configurar servidores personalizados
log "Setting up custom MCP servers..."
cd "$PROJECT_DIR/mcp-servers"

# Instalar dependencias
log "Installing dependencies for custom servers..."
npm install

# Hacer ejecutables
chmod +x oracle-cloud-server.js
chmod +x enhanced-cloudflare-server.js

# Paso 4: Configurar OCI CLI si no está instalado
if ! command -v oci &> /dev/null; then
    warn "OCI CLI not found. Installing..."
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
    log "OCI CLI installed. You'll need to run 'oci setup config' manually."
else
    log "OCI CLI already installed."
fi

# Paso 5: Crear directorio de configuración Claude Desktop
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Paso 6: Crear plantilla de configuración
log "Creating MCP configuration template..."
cat > "$CLAUDE_CONFIG_DIR/claude_desktop_config.json.template" << EOF
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "$HOME"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-sequential-thinking"]
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
      }
    },
    "cloudflare-official": {
      "command": "npx",
      "args": ["@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "YOUR_CLOUDFLARE_TOKEN_HERE"
      }
    },
    "cloudflare-enhanced": {
      "command": "node",
      "args": ["$PROJECT_DIR/mcp-servers/enhanced-cloudflare-server.js"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "YOUR_CLOUDFLARE_ENHANCED_TOKEN_HERE"
      }
    },
    "oracle-cloud": {
      "command": "node",
      "args": ["$PROJECT_DIR/mcp-servers/oracle-cloud-server.js"],
      "env": {
        "OCI_CONFIG_FILE": "~/.oci/config",
        "OCI_CONFIG_PROFILE": "DEFAULT"
      }
    }
  }
}
EOF

# Paso 7: Crear script de configuración interactiva
log "Creating interactive configuration script..."
cat > "$PROJECT_DIR/configure-tokens.sh" << 'EOF'
#!/bin/bash

# Script interactivo para configurar tokens
CONFIG_DIR="$HOME/Library/Application Support/Claude"
TEMPLATE_FILE="$CONFIG_DIR/claude_desktop_config.json.template"
CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

echo "🔑 MCP Tokens Configuration"
echo "============================"

# Leer tokens
echo "Please provide your API tokens:"
echo ""

read -p "GitHub Personal Access Token: " GITHUB_TOKEN
read -p "Cloudflare API Token (basic): " CLOUDFLARE_TOKEN
read -p "Cloudflare API Token (enhanced - optional): " CLOUDFLARE_ENHANCED_TOKEN

# Si no hay token enhanced, usar el básico
if [ -z "$CLOUDFLARE_ENHANCED_TOKEN" ]; then
    CLOUDFLARE_ENHANCED_TOKEN="$CLOUDFLARE_TOKEN"
fi

# Crear configuración final
cp "$TEMPLATE_FILE" "$CONFIG_FILE"

# Reemplazar tokens
sed -i '' "s/YOUR_GITHUB_TOKEN_HERE/$GITHUB_TOKEN/g" "$CONFIG_FILE"
sed -i '' "s/YOUR_CLOUDFLARE_TOKEN_HERE/$CLOUDFLARE_TOKEN/g" "$CONFIG_FILE"
sed -i '' "s/YOUR_CLOUDFLARE_ENHANCED_TOKEN_HERE/$CLOUDFLARE_ENHANCED_TOKEN/g" "$CONFIG_FILE"

echo "✅ Configuration saved to: $CONFIG_FILE"
echo "🔄 Please restart Claude Desktop to apply changes."
EOF

chmod +x "$PROJECT_DIR/configure-tokens.sh"

# Paso 8: Crear script de testing
log "Creating test script..."
cat > "$PROJECT_DIR/test-mcp-servers.sh" << 'EOF'
#!/bin/bash

echo "🧪 Testing MCP Servers"
echo "====================="

# Test basic servers
echo "Testing basic MCP servers..."
npx @modelcontextprotocol/server-filesystem --help > /dev/null 2>&1 && echo "✅ Filesystem server" || echo "❌ Filesystem server"
npx @modelcontextprotocol/server-github --help > /dev/null 2>&1 && echo "✅ GitHub server" || echo "❌ GitHub server"
npx @modelcontextprotocol/server-sequential-thinking --help > /dev/null 2>&1 && echo "✅ Sequential thinking server" || echo "❌ Sequential thinking server"

# Test Cloudflare server
npx @cloudflare/mcp-server-cloudflare --help > /dev/null 2>&1 && echo "✅ Cloudflare official server" || echo "❌ Cloudflare official server"

# Test custom servers
echo ""
echo "Testing custom servers..."
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$PROJECT_DIR/mcp-servers/enhanced-cloudflare-server.js" ]; then
    echo "✅ Enhanced Cloudflare server file exists"
else
    echo "❌ Enhanced Cloudflare server file missing"
fi

if [ -f "$PROJECT_DIR/mcp-servers/oracle-cloud-server.js" ]; then
    echo "✅ Oracle Cloud server file exists"
else
    echo "❌ Oracle Cloud server file missing"
fi

# Test OCI CLI
if command -v oci &> /dev/null; then
    echo "✅ OCI CLI installed"
else
    echo "❌ OCI CLI not installed"
fi

echo ""
echo "Configuration:"
CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Claude Desktop config exists"
else
    echo "❌ Claude Desktop config missing - run configure-tokens.sh"
fi
EOF

chmod +x "$PROJECT_DIR/test-mcp-servers.sh"

# Paso 9: Crear documentación de inicio rápido
log "Creating quick start guide..."
cat > "$PROJECT_DIR/QUICK-START.md" << 'EOF'
# 🚀 Quick Start Guide

## 1. Configure API Tokens
```bash
./configure-tokens.sh
```

## 2. Test Installation
```bash
./test-mcp-servers.sh
```

## 3. Configure OCI (if using Oracle Cloud)
```bash
oci setup config
```

## 4. Restart Claude Desktop

## 5. Test Commands in Claude:
- "List my GitHub repositories"
- "Create DNS record for test.example.com"
- "List Oracle Cloud instances"
- "Optimize Cloudflare settings for n8n"

## Documentation:
- [Enhanced MCP Config](ENHANCED-MCP-CONFIG.md)
- [Cloudflare Setup](CLOUDFLARE-SETUP.md)
- [MCP Servers Setup](MCP-SERVERS-SETUP.md)
EOF

echo "=================================================="
success "🎉 Enhanced MCP Servers setup completed!"
echo ""
warn "NEXT STEPS:"
echo "1. Run: ./configure-tokens.sh (to configure your API tokens)"
echo "2. Run: oci setup config (if using Oracle Cloud)"
echo "3. Restart Claude Desktop"
echo "4. Run: ./test-mcp-servers.sh (to verify installation)"
echo ""
log "📖 Documentation available in:"
echo "   - QUICK-START.md"
echo "   - ENHANCED-MCP-CONFIG.md"
echo "   - CLOUDFLARE-SETUP.md"
echo ""
success "Happy automating! 🤖"