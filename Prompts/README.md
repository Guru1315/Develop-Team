# Prompts

The prompt used by each node in the **Flowise** Agentflow. Copy a file's contents into the matching node's prompt field if you want to rebuild the flow by hand. (The n8n version keeps its own copies in [`../n8n/prompts/`](../n8n/prompts/).)

| File | Flow node | Writes to Flow State |
|---|---|---|
| [`product-manager.md`](product-manager.md) | Product Manager | `spec` |
| [`architect.md`](architect.md) | Architect | `design` |
| [`developer.md`](developer.md) | Developer | `code` |
| [`tester.md`](tester.md) | Tester | `bugs` |
| [`round-counter.js`](round-counter.js) | Round Counter (Custom Function) | `round` |
| [`supervisor.md`](supervisor.md) | Supervisor (Condition Agent) | none, only routes |
| [`direct-reply.md`](direct-reply.md) | Direct Reply | none, formats the final answer |

## How the prompts connect

Agents do not talk to each other directly. They read and write shared **Flow State**, and the prompts pull values in with the `{{ $flow.state.<name> }}` syntax:

- The Architect reads `spec`.
- The Developer reads `spec`, `design`, its own previous `code`, and `bugs`, so on a later round it fixes the listed bugs instead of starting over.
- The Tester reads `spec` and `code`.
- The Supervisor reads `spec` and `bugs`.
- Direct Reply assembles `spec`, `design`, `code` and `bugs` into the final package.

## Things worth knowing

- **The Tester's last line matters.** It must be exactly `VERDICT: PASS` or `VERDICT: FAIL`. The Supervisor's scenario 0 depends on spotting a pass, and small models often get this line wrong.
- **The Supervisor picks one of three scenarios**: finish (0), loop back to the Developer to fix bugs (1), or loop back to the Architect to redo the design (2).
- **`round-counter.js`** is not a prompt. It is the Custom Function body that adds 1 to `round` each pass, which feeds the `round >= 3` safety stop.
- Length limits are written into the prompts on purpose (Product Manager under 300 words, Architect under 250) to keep small local models focused.
