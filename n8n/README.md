# n8n version

The same Mini AI Software Dev Team, rebuilt in **n8n** (n8n Cloud, also works self-hosted).

## Flow

```
Chat Trigger -> Product Manager -> Architect -> Developer -> Tester -> Round Counter -> If (PASS or round >= 3)
                                                    ^                                     |true      |false
                                                    |                                     v          |
                                                    +-------------------------------------+---- Final Package -> Extract Code -> Convert to File -> Reply
                                                         (false branch loops back to Developer)
```

## Nodes

| Node | Type | Purpose |
|---|---|---|
| When chat message received | Chat Trigger | Takes the user's request |
| Product Manager | AI Agent | Writes the spec |
| Architect | AI Agent | Writes the design from the spec |
| Developer | AI Agent | Writes the code; fixes bugs on later rounds |
| Tester | AI Agent | Writes tests, lists bugs, ends with `VERDICT: PASS/FAIL` |
| Round Counter | Code | `$runIndex + 1` counts loop rounds |
| Pass or Limit | If | True when report contains `VERDICT: PASS` OR round >= 3 |
| Final Package | Edit Fields | Joins Spec, Design, Code and Test Report into `output` |
| Extract Code | Code | Pulls the Python code block out of the Developer's reply |
| Convert to File | Convert to File | Makes a downloadable `app.py` |
| Reply | Edit Fields | Keeps the chat answer as the full package |

There is no Flow State in n8n. Each node reads earlier results by name, for example
`{{ $('Product Manager').first().json.output }}`.

## Models used

Each AI Agent has its own Chat Model sub-node.

| Agent | Model |
|---|---|
| Product Manager, Architect | Google Gemini (flash) |
| Developer, Tester | Anthropic Claude |

Ollama cannot be used from n8n Cloud because the cloud cannot reach `localhost` on your PC.
Run n8n locally in Docker if you want Ollama.

## Run it

1. Open n8n and create a new workflow.
2. Import `n8n/software-dev-team.json` (menu -> Import from file).
3. Create your own credentials (Gemini, Anthropic) and select them in each Chat Model node.
4. Open the chat and send, for example:
   ```
   Build a Python CLI that checks password strength. It should score length, uppercase, lowercase, digits and symbols, label the password Weak, Medium or Strong, and give tips to improve it. Single file, no external libraries.
   ```
5. Double-click **Convert to File**, open the **Binary** tab and download `app.py`.

Never commit API keys. Credentials are not exported with the workflow, but search the JSON for `sk-` and `AIza` before pushing.

## Findings

- The Tester returned `VERDICT: PASS` without running the code, so a program that printed nothing without an argument got through. This is the main argument for a Tester that really executes code.
- Copying code from chat by hand picked up trailing markdown and caused a `SyntaxError`; the Extract Code node removes that step.
- Stronger models on Developer and Tester cut a full run from about two minutes to under 40 seconds.
