# System Architecture

Screenshots of the team as it looks in each tool: the Flowise canvas and the n8n workflow.

## Flowise: Software Dev Team

![Flowise canvas for the Software Dev Team flow](Screenshot%202026-10-23%20203102.png)

| Node | Type | Notes |
|---|---|---|
| Start | Start | Receives the user's feature request |
| Product Manager | Agent | Model: `qwen2.5-coder:1.5b` |
| Architect | Agent | Model: `qwen2.5-coder:1.5b` |
| Developer | Agent | Model: `qwen2.5-coder:1.5b` |
| Tester | Agent | Model: `qwen2.5-coder:1.5b` |
| Round Counter | Custom Function | Adds 1 to `round` |
| Condition 0 | Condition | Hard stop on the round limit |
| Supervisor | Condition Agent | Model: `qwen2.5-coder:1.5b`, three outputs (0, 1, 2) |
| Direct Reply 0 | Direct Reply | Sends the final package to the chat |
| Loop 0, Loop 1 | Loop | Send control back for another pass |

How control flows:

- The main line runs Product Manager, Architect, Developer, Tester, then Round Counter.
- **Condition 0** checks the round count. One branch goes straight to Direct Reply; the other goes to the Supervisor.
- The **Supervisor** has three outputs: output 0 goes to Direct Reply, output 1 goes to Loop 0, and output 2 goes to Loop 1. The scenarios map to these as finish, fix the code, and redo the design.

## n8n: Software Dev Team (Web)

![n8n workflow for the web console version](Screenshot%202026-10-24%20164605.png)

This is the n8n workflow behind the [web console](../web/README.md). Left to right:

| Node | Type | Purpose |
|---|---|---|
| Webhook | Webhook | Receives `{ run_id, request }` from the web page |
| Load Config | Supabase | Reads each agent's saved prompt, model and temperature |
| Config | Code | Packs the settings and the request into one item |
| Product Manager, Architect, Developer, Tester | AI Agent | The four agents, each with its own chat model |
| Round Counter | Code | Counts loop rounds |
| If | If | `true` goes on to Final Package, `false` loops back to Developer |
| Final Package | Edit Fields | Joins Spec, Design, Code and Test Report |
| Extract Code | Code | Pulls the code block out of the Developer's reply |
| Convert to File | Convert to File | Makes a downloadable file |
| Reply | Edit Fields | Returns the full package |

Four chat models are attached under the agents: two **Google Gemini** and two **Anthropic**.

The screenshot was taken before any run (the Logs panel is empty). The extra steps described in `web/README.md`, such as writing each agent's output to Supabase, are not visible in it.

For the same flow as a diagram, the agent roles and the Flowise-versus-n8n comparison, see the [main README](../README.md#architecture).
