# Outputs

Screenshots from the Flowise run inspector, showing what the team actually produced for the sample request `Build a CLI to-do app in Python with add, list, and delete.`

## Supervisor node

![Supervisor node run details](Screenshot%202026-10-23%20202652.png)

The Supervisor's run details: it took about 24 seconds and used 2,334 tokens with the local `qwen2.5-coder:1.5b` model. The raw record has `input`, `output`, `state` and `chatHistory` sections.

## Final state

![Condition output and final Flow State](Screenshot%202026-10-23%20202752.png)

The Condition output marked as fulfilled, followed by the final Flow State. It contains the generated Python CLI in `code`, `bugs` set to `No bugs found.`, and `round` set to `1`.

## Notes

- These are screenshots of one run with a small local model. Results vary between runs and between models.
- To see this for your own run, open the chat, expand the Process Flow and click a node's expand icon.
- A written-out sample of the final package belongs in [`../example/`](../example/).
- Findings from n8n runs (such as a Tester passing code that was never executed) are in [`../n8n/README.md`](../n8n/README.md#findings).
