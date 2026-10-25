# Crew Workflows

A screenshot of a real run of the Flowise version of the team, taken from the Flowise chat window.

![Process Flow of a completed run](Screenshot%202026-10-23%20202837.png)

## What the screenshot shows

The **Process Flow** panel lists each node in the order it executed, and every step shows a green check:

1. **Start**
2. **Product Manager**
3. **Architect**
4. **Developer**
5. **Tester**
6. **Round Counter**
7. **Condition 0**
8. **Supervisor**

Below the trace, the Supervisor's decision is shown as JSON. In this run it concluded that the test report ended with `VERDICT: PASS` (or reported no bugs), so the work was finished.

## Reading a run yourself

- Expand any node in the Process Flow to see its input, output and the Flow State at that point.
- Each node also reports how long it took and how many tokens it used, which is useful when comparing a local model against a cloud one.
- If a run loops, the same Developer, Tester, Round Counter and Supervisor steps will appear again in the trace.

For runs of the n8n version, use n8n's **Executions** tab instead (see [`../n8n/`](../n8n/)).
