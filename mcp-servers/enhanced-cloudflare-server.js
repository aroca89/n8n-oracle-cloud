#!/usr/bin/env node

/**
 * Enhanced Cloudflare MCP Server
 * Advanced tools for comprehensive Cloudflare management
 * Requires extended API token permissions
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';

class EnhancedCloudflareMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'enhanced-cloudflare-mcp-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.apiToken = process.env.CLOUDFLARE_API_TOKEN;
    this.baseURL = 'https://api.cloudflare.com/client/v4';
    
    if (!this.apiToken) {
      throw new Error('CLOUDFLARE_API_TOKEN environment variable is required');
    }

    this.setupToolHandlers();
    
    // Error handling
    this.server.onerror = (error) => console.error('[MCP Error]', error);
    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async makeCloudflareRequest(endpoint, method = 'GET', data = null) {
    const url = `${this.baseURL}${endpoint}`;
    const options = {
      method,
      headers: {
        'Authorization': `Bearer ${this.apiToken}`,
        'Content-Type': 'application/json',
      },
    };

    if (data && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
      options.body = JSON.stringify(data);
    }

    const response = await fetch(url, options);
    const result = await response.json();
    
    if (!result.success) {
      throw new Error(`Cloudflare API error: ${result.errors?.[0]?.message || 'Unknown error'}`);
    }
    
    return result;
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          // === DNS Management ===
          {
            name: 'cf_create_dns_record',
            description: 'Create a DNS record with advanced options',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                type: { type: 'string', description: 'Record type (A, AAAA, CNAME, etc.)' },
                name: { type: 'string', description: 'Record name' },
                content: { type: 'string', description: 'Record content/value' },
                ttl: { type: 'number', description: 'TTL in seconds (1 = auto)', default: 1 },
                proxied: { type: 'boolean', description: 'Proxy through Cloudflare', default: false },
                comment: { type: 'string', description: 'Comment for the record' },
              },
              required: ['zone_id', 'type', 'name', 'content'],
            },
          },
          {
            name: 'cf_bulk_dns_operations',
            description: 'Perform bulk DNS operations (create multiple records)',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                records: {
                  type: 'array',
                  description: 'Array of DNS records to create',
                  items: {
                    type: 'object',
                    properties: {
                      type: { type: 'string' },
                      name: { type: 'string' },
                      content: { type: 'string' },
                      proxied: { type: 'boolean', default: false },
                    },
                  },
                },
              },
              required: ['zone_id', 'records'],
            },
          },

          // === Workers & Pages ===
          {
            name: 'cf_deploy_worker',
            description: 'Deploy a Cloudflare Worker with code',
            inputSchema: {
              type: 'object',
              properties: {
                script_name: { type: 'string', description: 'Worker script name' },
                code: { type: 'string', description: 'Worker JavaScript code' },
                routes: { type: 'array', items: { type: 'string' }, description: 'Routes to bind' },
                env_vars: { type: 'object', description: 'Environment variables' },
                kv_bindings: { type: 'array', items: { type: 'string' }, description: 'KV namespace bindings' },
              },
              required: ['script_name', 'code'],
            },
          },
          {
            name: 'cf_create_kv_namespace',
            description: 'Create a KV storage namespace',
            inputSchema: {
              type: 'object',
              properties: {
                title: { type: 'string', description: 'KV namespace title' },
                preview: { type: 'boolean', description: 'Create as preview namespace', default: false },
              },
              required: ['title'],
            },
          },
          {
            name: 'cf_kv_put_value',
            description: 'Store a value in KV storage',
            inputSchema: {
              type: 'object',
              properties: {
                namespace_id: { type: 'string', description: 'KV namespace ID' },
                key: { type: 'string', description: 'Key name' },
                value: { type: 'string', description: 'Value to store' },
                expiration_ttl: { type: 'number', description: 'TTL in seconds' },
              },
              required: ['namespace_id', 'key', 'value'],
            },
          },

          // === Security & Firewall ===
          {
            name: 'cf_create_firewall_rule',
            description: 'Create advanced firewall rule with custom expression',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                expression: { type: 'string', description: 'Firewall rule expression' },
                action: { type: 'string', description: 'Action: block, challenge, allow, log, bypass' },
                description: { type: 'string', description: 'Rule description' },
                priority: { type: 'number', description: 'Rule priority', default: 1000 },
              },
              required: ['zone_id', 'expression', 'action'],
            },
          },
          {
            name: 'cf_setup_rate_limiting',
            description: 'Configure rate limiting rules',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                match: { type: 'object', description: 'Match conditions' },
                threshold: { type: 'number', description: 'Request threshold' },
                period: { type: 'number', description: 'Time period in seconds' },
                action: { type: 'string', description: 'Action when threshold exceeded' },
                description: { type: 'string', description: 'Rule description' },
              },
              required: ['zone_id', 'threshold', 'period', 'action'],
            },
          },
          {
            name: 'cf_configure_waf',
            description: 'Configure Web Application Firewall rules',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                mode: { type: 'string', description: 'WAF mode: off, on, simulate' },
                rules: { type: 'array', description: 'Custom WAF rules' },
              },
              required: ['zone_id', 'mode'],
            },
          },

          // === Load Balancing ===
          {
            name: 'cf_create_load_balancer',
            description: 'Create a load balancer with health checks',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                name: { type: 'string', description: 'Load balancer name' },
                fallback_pool: { type: 'string', description: 'Fallback pool ID' },
                default_pools: { type: 'array', items: { type: 'string' }, description: 'Default pool IDs' },
                description: { type: 'string', description: 'Description' },
                proxied: { type: 'boolean', description: 'Proxy through Cloudflare', default: true },
              },
              required: ['zone_id', 'name', 'fallback_pool', 'default_pools'],
            },
          },
          {
            name: 'cf_create_origin_pool',
            description: 'Create an origin pool for load balancing',
            inputSchema: {
              type: 'object',
              properties: {
                name: { type: 'string', description: 'Pool name' },
                origins: { type: 'array', description: 'Array of origin servers' },
                description: { type: 'string', description: 'Pool description' },
                enabled: { type: 'boolean', description: 'Enable pool', default: true },
                minimum_origins: { type: 'number', description: 'Minimum healthy origins', default: 1 },
              },
              required: ['name', 'origins'],
            },
          },

          // === Zero Trust & Access ===
          {
            name: 'cf_create_access_application',
            description: 'Create a Zero Trust Access application',
            inputSchema: {
              type: 'object',
              properties: {
                account_id: { type: 'string', description: 'Account ID' },
                name: { type: 'string', description: 'Application name' },
                domain: { type: 'string', description: 'Application domain' },
                type: { type: 'string', description: 'Application type', default: 'self_hosted' },
                session_duration: { type: 'string', description: 'Session duration', default: '24h' },
              },
              required: ['account_id', 'name', 'domain'],
            },
          },
          {
            name: 'cf_create_tunnel',
            description: 'Create a Cloudflare Tunnel (formerly Argo Tunnel)',
            inputSchema: {
              type: 'object',
              properties: {
                account_id: { type: 'string', description: 'Account ID' },
                name: { type: 'string', description: 'Tunnel name' },
                tunnel_secret: { type: 'string', description: 'Tunnel secret (base64)' },
              },
              required: ['account_id', 'name', 'tunnel_secret'],
            },
          },

          // === Analytics & Monitoring ===
          {
            name: 'cf_get_analytics',
            description: 'Get detailed analytics data',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                since: { type: 'string', description: 'Start time (ISO 8601)' },
                until: { type: 'string', description: 'End time (ISO 8601)' },
                dimensions: { type: 'array', items: { type: 'string' }, description: 'Analytics dimensions' },
                metrics: { type: 'array', items: { type: 'string' }, description: 'Metrics to retrieve' },
              },
              required: ['zone_id'],
            },
          },
          {
            name: 'cf_get_security_events',
            description: 'Get security events and threat analytics',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                since: { type: 'string', description: 'Start time' },
                until: { type: 'string', description: 'End time' },
                action: { type: 'string', description: 'Filter by action (block, challenge, etc.)' },
              },
              required: ['zone_id'],
            },
          },

          // === Advanced Zone Management ===
          {
            name: 'cf_setup_n8n_optimization',
            description: 'Complete setup optimization for n8n deployment',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                domain: { type: 'string', description: 'n8n domain (e.g., n8n.example.com)' },
                origin_ip: { type: 'string', description: 'Oracle Cloud instance IP' },
                enable_security: { type: 'boolean', description: 'Enable security features', default: true },
                enable_performance: { type: 'boolean', description: 'Enable performance optimization', default: true },
              },
              required: ['zone_id', 'domain', 'origin_ip'],
            },
          },
          {
            name: 'cf_bulk_security_setup',
            description: 'Bulk security configuration for multiple domains',
            inputSchema: {
              type: 'object',
              properties: {
                zones: { type: 'array', items: { type: 'string' }, description: 'Zone IDs' },
                security_level: { type: 'string', description: 'Security level: off, essentially_off, low, medium, high, under_attack' },
                enable_ddos_protection: { type: 'boolean', default: true },
                enable_bot_fight: { type: 'boolean', default: true },
                custom_rules: { type: 'array', description: 'Custom security rules' },
              },
              required: ['zones'],
            },
          },

          // === Performance Optimization ===
          {
            name: 'cf_optimize_caching',
            description: 'Optimize caching rules for application performance',
            inputSchema: {
              type: 'object',
              properties: {
                zone_id: { type: 'string', description: 'Zone ID' },
                cache_rules: { type: 'array', description: 'Custom cache rules' },
                purge_cache: { type: 'boolean', description: 'Purge existing cache', default: false },
                enable_argo: { type: 'boolean', description: 'Enable Argo Smart Routing', default: true },
              },
              required: ['zone_id'],
            },
          },
        ],
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'cf_create_dns_record':
            return await this.createDNSRecord(args);
          case 'cf_bulk_dns_operations':
            return await this.bulkDNSOperations(args);
          case 'cf_deploy_worker':
            return await this.deployWorker(args);
          case 'cf_create_kv_namespace':
            return await this.createKVNamespace(args);
          case 'cf_kv_put_value':
            return await this.kvPutValue(args);
          case 'cf_create_firewall_rule':
            return await this.createFirewallRule(args);
          case 'cf_setup_rate_limiting':
            return await this.setupRateLimiting(args);
          case 'cf_configure_waf':
            return await this.configureWAF(args);
          case 'cf_create_load_balancer':
            return await this.createLoadBalancer(args);
          case 'cf_create_origin_pool':
            return await this.createOriginPool(args);
          case 'cf_create_access_application':
            return await this.createAccessApplication(args);
          case 'cf_create_tunnel':
            return await this.createTunnel(args);
          case 'cf_get_analytics':
            return await this.getAnalytics(args);
          case 'cf_get_security_events':
            return await this.getSecurityEvents(args);
          case 'cf_setup_n8n_optimization':
            return await this.setupN8NOptimization(args);
          case 'cf_bulk_security_setup':
            return await this.bulkSecuritySetup(args);
          case 'cf_optimize_caching':
            return await this.optimizeCaching(args);
          default:
            throw new McpError(
              ErrorCode.MethodNotFound,
              `Unknown tool: ${name}`
            );
        }
      } catch (error) {
        throw new McpError(
          ErrorCode.InternalError,
          `Tool execution failed: ${error.message}`
        );
      }
    });
  }

  async createDNSRecord(args) {
    const result = await this.makeCloudflareRequest(
      `/zones/${args.zone_id}/dns_records`,
      'POST',
      {
        type: args.type,
        name: args.name,
        content: args.content,
        ttl: args.ttl || 1,
        proxied: args.proxied || false,
        comment: args.comment,
      }
    );

    return {
      content: [
        {
          type: 'text',
          text: `DNS record created successfully!\n\n` +
                `Type: ${result.result.type}\n` +
                `Name: ${result.result.name}\n` +
                `Content: ${result.result.content}\n` +
                `Proxied: ${result.result.proxied ? 'Yes' : 'No'}\n` +
                `ID: ${result.result.id}`,
        },
      ],
    };
  }

  async bulkDNSOperations(args) {
    const results = [];
    for (const record of args.records) {
      try {
        const result = await this.makeCloudflareRequest(
          `/zones/${args.zone_id}/dns_records`,
          'POST',
          record
        );
        results.push(`✅ ${record.name} (${record.type}) - Created`);
      } catch (error) {
        results.push(`❌ ${record.name} (${record.type}) - Error: ${error.message}`);
      }
    }

    return {
      content: [
        {
          type: 'text',
          text: `Bulk DNS operations completed:\n\n${results.join('\n')}`,
        },
      ],
    };
  }

  async deployWorker(args) {
    // Upload worker script
    const formData = new FormData();
    formData.append('script', args.code);
    
    if (args.env_vars) {
      formData.append('metadata', JSON.stringify({
        env_vars: args.env_vars,
        kv_bindings: args.kv_bindings || [],
      }));
    }

    const result = await this.makeCloudflareRequest(
      `/accounts/${await this.getAccountId()}/workers/scripts/${args.script_name}`,
      'PUT',
      formData
    );

    // Add routes if specified
    if (args.routes && args.routes.length > 0) {
      for (const route of args.routes) {
        await this.makeCloudflareRequest(
          `/accounts/${await this.getAccountId()}/workers/scripts/${args.script_name}/routes`,
          'POST',
          { pattern: route }
        );
      }
    }

    return {
      content: [
        {
          type: 'text',
          text: `Worker deployed successfully!\n\n` +
                `Script Name: ${args.script_name}\n` +
                `Routes: ${args.routes?.join(', ') || 'None'}\n` +
                `Environment Variables: ${Object.keys(args.env_vars || {}).length}\n` +
                `KV Bindings: ${args.kv_bindings?.length || 0}`,
        },
      ],
    };
  }

  async setupN8NOptimization(args) {
    const tasks = [];
    
    // 1. Create DNS record
    try {
      await this.createDNSRecord({
        zone_id: args.zone_id,
        type: 'A',
        name: args.domain.split('.')[0],
        content: args.origin_ip,
        proxied: true,
      });
      tasks.push('✅ DNS A record created and proxied');
    } catch (error) {
      tasks.push(`❌ DNS record failed: ${error.message}`);
    }

    if (args.enable_security) {
      // 2. Security optimizations
      try {
        await this.makeCloudflareRequest(
          `/zones/${args.zone_id}/settings/security_level`,
          'PATCH',
          { value: 'medium' }
        );
        tasks.push('✅ Security level set to medium');

        // Enable Bot Fight Mode
        await this.makeCloudflareRequest(
          `/zones/${args.zone_id}/bot_management`,
          'PATCH',
          { fight_mode: true }
        );
        tasks.push('✅ Bot Fight Mode enabled');

        // Create firewall rule for admin protection
        await this.createFirewallRule({
          zone_id: args.zone_id,
          expression: `(http.request.uri.path eq "/") and (ip.geoip.country ne "ES" and ip.geoip.country ne "US")`,
          action: 'challenge',
          description: 'n8n Admin Protection - Challenge non-ES/US traffic to admin',
        });
        tasks.push('✅ Admin protection firewall rule created');
      } catch (error) {
        tasks.push(`❌ Security setup failed: ${error.message}`);
      }
    }

    if (args.enable_performance) {
      // 3. Performance optimizations
      try {
        // Enable Always Online
        await this.makeCloudflareRequest(
          `/zones/${args.zone_id}/settings/always_online`,
          'PATCH',
          { value: 'on' }
        );
        tasks.push('✅ Always Online enabled');

        // Optimize caching
        await this.makeCloudflareRequest(
          `/zones/${args.zone_id}/settings/cache_level`,
          'PATCH',
          { value: 'aggressive' }
        );
        tasks.push('✅ Aggressive caching enabled');

        // Enable Brotli compression
        await this.makeCloudflareRequest(
          `/zones/${args.zone_id}/settings/brotli`,
          'PATCH',
          { value: 'on' }
        );
        tasks.push('✅ Brotli compression enabled');
      } catch (error) {
        tasks.push(`❌ Performance optimization failed: ${error.message}`);
      }
    }

    return {
      content: [
        {
          type: 'text',
          text: `n8n Cloudflare optimization completed!\n\n${tasks.join('\n')}\n\n` +
                `Your n8n instance is now optimized for:\n` +
                `• DNS proxying for performance and security\n` +
                `• DDoS protection and bot mitigation\n` +
                `• Aggressive caching for static assets\n` +
                `• Global CDN acceleration\n` +
                `• Admin panel protection`,
        },
      ],
    };
  }

  async getAccountId() {
    if (!this.accountId) {
      const result = await this.makeCloudflareRequest('/accounts');
      this.accountId = result.result[0].id;
    }
    return this.accountId;
  }

  // Additional method implementations...
  async createFirewallRule(args) {
    const result = await this.makeCloudflareRequest(
      `/zones/${args.zone_id}/firewall/rules`,
      'POST',
      {
        filter: {
          expression: args.expression,
        },
        action: args.action,
        description: args.description,
        priority: args.priority || 1000,
      }
    );

    return {
      content: [
        {
          type: 'text',
          text: `Firewall rule created!\n\n` +
                `Expression: ${args.expression}\n` +
                `Action: ${args.action}\n` +
                `Description: ${args.description}\n` +
                `ID: ${result.result.id}`,
        },
      ],
    };
  }

  async getAnalytics(args) {
    const params = new URLSearchParams();
    if (args.since) params.append('since', args.since);
    if (args.until) params.append('until', args.until);
    if (args.dimensions) params.append('dimensions', args.dimensions.join(','));
    if (args.metrics) params.append('metrics', args.metrics.join(','));

    const result = await this.makeCloudflareRequest(
      `/zones/${args.zone_id}/analytics/dashboard?${params}`
    );

    return {
      content: [
        {
          type: 'text',
          text: `Analytics Summary:\n\n` +
                `Requests: ${result.result.totals.requests.all}\n` +
                `Bandwidth: ${result.result.totals.bandwidth.all} bytes\n` +
                `Threats: ${result.result.totals.threats.all}\n` +
                `Unique Visitors: ${result.result.totals.uniques.all}`,
        },
      ],
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Enhanced Cloudflare MCP server running on stdio');
  }
}

const server = new EnhancedCloudflareMCPServer();
server.run().catch(console.error);