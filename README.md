# Develop Team: Multi-Agent Software Dev Team

A multi-agent software engineering team built visually in **Flowise (Agentflow)** and rebuilt in **n8n** (see [`n8n/`](n8n/)). Give it a feature request in plain English and a team of AI agents produces a spec, a design, code, and a test report, looping between Developer and Tester until the code passes or a round limit is reached.

## Architecture

```
User request
     |
     v
Product Manager --> Architect --> Developer --> Tester --> Round Counter --> Condition (round >= 3?)
                                      ^                                          |yes        |no
                                      |                                          v           v
                                      |                                    Direct Reply   Supervisor (Condition Agent)
                                      |                                          ^           |
                                      +------ Loop (fix code) <-- scenario 1 ----+-----------+
                                      +------ Loop (redo design -> Architect) <-- scenario 2
                                                                  scenario 0 (PASS) --> Direct Reply
```

Shared memory between agents is Flowise **Flow State**: `spec`, `design`, `code`, `bugs`, `round`.

## Agents

| Agent | Role | Writes to state |
|---|---|---|
| Product Manager | Turns the request into user stories and acceptance criteria | `spec` |
| Architect | Chooses libraries, file structure, function list | `design` |
| Developer | Writes complete code, fixes reported bugs | `code` |
| Tester | Writes pytest cases, lists bugs, ends with `VERDICT: PASS/FAIL` | `bugs` |
| Round Counter | Custom Function that adds 1 to `round` | `round` |
| Supervisor | Condition Agent that routes: Finish, back to Developer, or back to Architect | - |

A plain Condition node acts as a hard safety stop (`round >= 3`), so a weak model can never loop forever.

## Tech stack

- Flowise 3.1.3 (Docker)
- Ollama with `qwen2.5-coder:1.5b` (local, free)
- Optional: Google Gemini via `ChatGoogleGenerativeAI` for stronger Developer, Tester and Supervisor

Each agent node has its own model setting, so you can mix local and cloud models.

## How to run

1. Start Flowise:
   ```bash
   docker run -d --name flowise --user root -p 3000:3000 -v flowise_data:/root/.flowise flowiseai/flowise:3.1.3
   ```
2. Open http://localhost:3000 and create an account.
3. Install Ollama and pull the model:
   ```bash
   ollama pull qwen2.5-coder:1.5b
   ```
4. In Flowise go to **Agentflows -> Add New -> settings gear -> Load Agentflow** and import `flow/software-dev-team.json`.
5. For Ollama nodes set Base URL to `http://host.docker.internal:11434` (because Flowise runs in Docker).
6. If you use Gemini, add your own key under **Credentials** and select it in the nodes. Never commit keys.
7. Open the chat and try:
   ```
   Build a CLI to-do app in Python with add, list, and delete.
   ```

The prompts for each agent are in [`Prompts/`](Prompts/) if you want to read or rebuild the flow by hand.

## Repository structure

| Folder | Contents |
|---|---|
| [`flow/`](flow/) | Where the exported Flowise JSON goes (`software-dev-team.json`, not added yet) |
| [`Prompts/`](Prompts/) | Flowise prompts for each node, plus the Round Counter function |
| [`n8n/`](n8n/) | The n8n version: prompts, code nodes and setup. The exported workflow JSON is not added yet |
| [`web/`](web/) | Single-page web console and its Supabase schema |
| [`System Architecture/`](System%20Architecture/) | Screenshots of the Flowise canvas and the n8n workflow |
| [`Crew Workflows/`](Crew%20Workflows/) | Screenshot of the Process Flow trace from a real run |
| [`Outputs/`](Outputs/) | Screenshots of node details and the final Flow State |
| [`example/`](example/) | Written sample of the final output |

## Example

See [`example/todo-app-output.md`](example/todo-app-output.md) for a sample run (replace with your own output).

## Web console

[`web/`](web/) has a single-page dashboard (n8n + Supabase) for running the team and editing each agent's prompt and model live. Setup is in [`web/README.md`](web/README.md).

## Flowise vs n8n

| | Flowise | n8n |
|---|---|---|
| Shared memory | Flow State (`spec`, `design`, `code`, `bugs`, `round`) | Read earlier nodes by name, e.g. `$('Architect').first().json.output` |
| Round counting | Custom Function node + Flow State | Code node using `$runIndex` |
| Routing | Condition + Condition Agent (Supervisor) | If node + loop back to Developer |
| Local models (Ollama) | Yes, with `host.docker.internal` in Docker | Not from n8n Cloud; yes if n8n runs locally |
| Final output | Direct Reply | Edit Fields + downloadable `app.py` |
| Folder | `Prompts/`, `flow/` | `n8n/` |

## Limitations and lessons learned

- A 1.5b model is slow on CPU and often misses the exact `VERDICT:` line, so loops usually hit the round cap.
- The Supervisor routes much better with a stronger model.
- The Tester reviews code by reading it; it does not execute it.
- Flowise Docker volumes must be writable; use `--user root` with a named volume.

## Future work

- Let the Tester actually run the code (E2B or a code-execution tool) and feed real errors into `bugs`
- Human Input approval step after the Product Manager
- Save final code to files or push to GitHub automatically
- Compare the team against a single LLM on tests passed and completeness

## License

MIT
