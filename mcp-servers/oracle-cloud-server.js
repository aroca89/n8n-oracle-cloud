#!/usr/bin/env node

/**
 * Oracle Cloud Infrastructure (OCI) MCP Server
 * Provides tools for managing Oracle Cloud resources through MCP
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';
import { spawn } from 'child_process';
import { promisify } from 'util';

const execFile = promisify(require('child_process').execFile);

class OCIMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'oracle-cloud-mcp-server',
        version: '0.1.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
    
    // Error handling
    this.server.onerror = (error) => console.error('[MCP Error]', error);
    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'oci_list_instances',
            description: 'List all compute instances in Oracle Cloud',
            inputSchema: {
              type: 'object',
              properties: {
                compartment_id: {
                  type: 'string',
                  description: 'Compartment OCID (optional, defaults to tenancy root)',
                },
                lifecycle_state: {
                  type: 'string',
                  description: 'Filter by lifecycle state (RUNNING, STOPPED, etc.)',
                },
              },
            },
          },
          {
            name: 'oci_start_instance',
            description: 'Start a stopped compute instance',
            inputSchema: {
              type: 'object',
              properties: {
                instance_id: {
                  type: 'string',
                  description: 'Instance OCID to start',
                  required: true,
                },
              },
              required: ['instance_id'],
            },
          },
          {
            name: 'oci_stop_instance',
            description: 'Stop a running compute instance',
            inputSchema: {
              type: 'object',
              properties: {
                instance_id: {
                  type: 'string',
                  description: 'Instance OCID to stop',
                  required: true,
                },
                action: {
                  type: 'string',
                  description: 'Stop action: STOP or SOFTSTOP',
                  default: 'STOP',
                },
              },
              required: ['instance_id'],
            },
          },
          {
            name: 'oci_get_instance_details',
            description: 'Get detailed information about a specific instance',
            inputSchema: {
              type: 'object',
              properties: {
                instance_id: {
                  type: 'string',
                  description: 'Instance OCID',
                  required: true,
                },
              },
              required: ['instance_id'],
            },
          },
          {
            name: 'oci_list_vcns',
            description: 'List Virtual Cloud Networks (VCNs)',
            inputSchema: {
              type: 'object',
              properties: {
                compartment_id: {
                  type: 'string',
                  description: 'Compartment OCID (optional)',
                },
              },
            },
          },
          {
            name: 'oci_create_instance',
            description: 'Create a new compute instance',
            inputSchema: {
              type: 'object',
              properties: {
                display_name: {
                  type: 'string',
                  description: 'Display name for the instance',
                  required: true,
                },
                shape: {
                  type: 'string',
                  description: 'Instance shape (e.g., VM.Standard.A1.Flex)',
                  default: 'VM.Standard.A1.Flex',
                },
                image_id: {
                  type: 'string',
                  description: 'OS image OCID',
                  required: true,
                },
                subnet_id: {
                  type: 'string',
                  description: 'Subnet OCID',
                  required: true,
                },
                compartment_id: {
                  type: 'string',
                  description: 'Compartment OCID',
                  required: true,
                },
                ssh_public_key: {
                  type: 'string',
                  description: 'SSH public key for access',
                  required: true,
                },
              },
              required: ['display_name', 'image_id', 'subnet_id', 'compartment_id', 'ssh_public_key'],
            },
          },
          {
            name: 'oci_setup_n8n_instance',
            description: 'Create and configure an instance optimized for n8n',
            inputSchema: {
              type: 'object',
              properties: {
                instance_name: {
                  type: 'string',
                  description: 'Name for the n8n instance',
                  default: 'n8n-automation-server',
                },
                compartment_id: {
                  type: 'string',
                  description: 'Compartment OCID',
                  required: true,
                },
                ssh_public_key: {
                  type: 'string',
                  description: 'SSH public key for access',
                  required: true,
                },
              },
              required: ['compartment_id', 'ssh_public_key'],
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
          case 'oci_list_instances':
            return await this.listInstances(args);
          case 'oci_start_instance':
            return await this.startInstance(args);
          case 'oci_stop_instance':
            return await this.stopInstance(args);
          case 'oci_get_instance_details':
            return await this.getInstanceDetails(args);
          case 'oci_list_vcns':
            return await this.listVCNs(args);
          case 'oci_create_instance':
            return await this.createInstance(args);
          case 'oci_setup_n8n_instance':
            return await this.setupN8NInstance(args);
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

  async executeOCICommand(command, args = []) {
    try {
      const result = await execFile('oci', [command, ...args, '--output', 'json']);
      return JSON.parse(result.stdout);
    } catch (error) {
      throw new Error(`OCI CLI error: ${error.message}`);
    }
  }

  async listInstances(args) {
    const ociArgs = ['compute', 'instance', 'list'];
    
    if (args.compartment_id) {
      ociArgs.push('--compartment-id', args.compartment_id);
    }
    
    if (args.lifecycle_state) {
      ociArgs.push('--lifecycle-state', args.lifecycle_state);
    }

    const result = await this.executeOCICommand('', ociArgs);
    
    return {
      content: [
        {
          type: 'text',
          text: `Found ${result.data.length} instances:\n\n` +
                result.data.map(instance => 
                  `• ${instance['display-name']} (${instance.id})\n` +
                  `  Status: ${instance['lifecycle-state']}\n` +
                  `  Shape: ${instance.shape}\n` +
                  `  Region: ${instance.region}\n`
                ).join('\n'),
        },
      ],
    };
  }

  async startInstance(args) {
    const result = await this.executeOCICommand('', [
      'compute', 'instance', 'action',
      '--instance-id', args.instance_id,
      '--action', 'START'
    ]);

    return {
      content: [
        {
          type: 'text',
          text: `Instance ${args.instance_id} start command sent successfully.\nCurrent state: ${result.data['lifecycle-state']}`,
        },
      ],
    };
  }

  async stopInstance(args) {
    const action = args.action || 'STOP';
    const result = await this.executeOCICommand('', [
      'compute', 'instance', 'action',
      '--instance-id', args.instance_id,
      '--action', action
    ]);

    return {
      content: [
        {
          type: 'text',
          text: `Instance ${args.instance_id} ${action.toLowerCase()} command sent successfully.\nCurrent state: ${result.data['lifecycle-state']}`,
        },
      ],
    };
  }

  async getInstanceDetails(args) {
    const result = await this.executeOCICommand('', [
      'compute', 'instance', 'get',
      '--instance-id', args.instance_id
    ]);

    const instance = result.data;
    return {
      content: [
        {
          type: 'text',
          text: `Instance Details:\n\n` +
                `Name: ${instance['display-name']}\n` +
                `ID: ${instance.id}\n` +
                `Status: ${instance['lifecycle-state']}\n` +
                `Shape: ${instance.shape}\n` +
                `Region: ${instance.region}\n` +
                `Availability Domain: ${instance['availability-domain']}\n` +
                `Time Created: ${instance['time-created']}\n` +
                `Compartment: ${instance['compartment-id']}`,
        },
      ],
    };
  }

  async listVCNs(args) {
    const ociArgs = ['network', 'vcn', 'list'];
    
    if (args.compartment_id) {
      ociArgs.push('--compartment-id', args.compartment_id);
    }

    const result = await this.executeOCICommand('', ociArgs);
    
    return {
      content: [
        {
          type: 'text',
          text: `Found ${result.data.length} VCNs:\n\n` +
                result.data.map(vcn => 
                  `• ${vcn['display-name']} (${vcn.id})\n` +
                  `  CIDR: ${vcn['cidr-block']}\n` +
                  `  State: ${vcn['lifecycle-state']}\n`
                ).join('\n'),
        },
      ],
    };
  }

  async createInstance(args) {
    const ociArgs = [
      'compute', 'instance', 'launch',
      '--display-name', args.display_name,
      '--shape', args.shape || 'VM.Standard.A1.Flex',
      '--image-id', args.image_id,
      '--subnet-id', args.subnet_id,
      '--compartment-id', args.compartment_id,
      '--ssh-authorized-keys-file', '/dev/stdin'
    ];

    // Create instance with SSH key
    const child = spawn('oci', ociArgs, {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    child.stdin.write(args.ssh_public_key);
    child.stdin.end();

    const stdout = await new Promise((resolve, reject) => {
      let data = '';
      child.stdout.on('data', chunk => data += chunk);
      child.on('close', code => {
        if (code === 0) resolve(data);
        else reject(new Error(`Process exited with code ${code}`));
      });
    });

    const result = JSON.parse(stdout);
    
    return {
      content: [
        {
          type: 'text',
          text: `Instance created successfully!\n\n` +
                `Name: ${result.data['display-name']}\n` +
                `ID: ${result.data.id}\n` +
                `Shape: ${result.data.shape}\n` +
                `Status: ${result.data['lifecycle-state']}\n\n` +
                `The instance is being provisioned. You can check its status with the get_instance_details tool.`,
        },
      ],
    };
  }

  async setupN8NInstance(args) {
    // This would create an instance optimized for n8n with proper security groups, etc.
    return {
      content: [
        {
          type: 'text',
          text: `Setting up n8n-optimized instance "${args.instance_name}"...\n\n` +
                `This tool would:\n` +
                `1. Create instance with Ubuntu 22.04\n` +
                `2. Configure security lists for ports 80, 443, 22\n` +
                `3. Set up cloud-init script for Docker installation\n` +
                `4. Configure firewall rules\n` +
                `5. Install our n8n repository automatically\n\n` +
                `Use the oci_create_instance tool for manual creation, or implement this for full automation.`,
        },
      ],
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Oracle Cloud MCP server running on stdio');
  }
}

const server = new OCIMCPServer();
server.run().catch(console.error);