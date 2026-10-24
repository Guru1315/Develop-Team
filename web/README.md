# Web console (n8n + Supabase)

A single-page dashboard for the Dev Team.

- **Run** a request and watch each agent's output arrive live.
- **Edit** each agent's prompt, model name and temperature on the page. Changes are saved to Supabase and used by the next run.
- **Download** the final package (`.md`) and the code (`app.py`).

```
Browser page  --POST {run_id, request}-->  n8n Webhook
     ^  \                                      |
     |   \__ edits agent_config                v
     |        (Supabase)  <---- n8n reads config at start, writes run_steps after each agent
     |__ Realtime: new run_steps / agent_config changes appear instantly
```

## 1. Supabase (5 minutes)

1. Open your project -> **SQL Editor** -> New query.
2. Paste all of [`supabase.sql`](supabase.sql) and **Run**. It creates `agent_config`, `runs`, `run_steps`, turns on Realtime, and seeds the four agents.
3. Open **Project Settings -> API** and copy the **Project URL** and the **anon public** key (for the page), and the **service_role** key (for n8n only).
4. In the `agent_config` table, set each `model` to the exact model name your n8n node uses.

## 2. n8n changes

Duplicate your workflow first (menu -> Duplicate) and name it `Software Dev Team (Web)`, so the chat version keeps working.

**a) Trigger.** Delete *When chat message received* and add a **Webhook** node:
- HTTP Method `POST`, Path `dev-team`
- **Respond:** `Immediately`
- Options -> **Allowed Origins (CORS):** `*`

**b) Load config.** After the Webhook add:
1. **Supabase -> Get many rows**. Credential: Supabase API (Host = your project URL, Service Role Secret = the service_role key). Table `agent_config`, **Return All** on.
2. A **Code** node named `Config`:
   ```javascript
   const cfg = {};
   for (const item of $input.all()) cfg[item.json.agent] = item.json;
   const body = $('Webhook').first().json.body;
   return [{ json: { cfg, run_id: body.run_id, request: body.request } }];
   ```

**c) Make each agent read its settings.** On every AI Agent, switch these fields to **Expression**:

| Field | Expression (example: Developer) |
|---|---|
| System Message (Options) | `{{ $('Config').first().json.cfg.developer.system_message }}` |
| Chat Model -> Model (use *By ID*) | `{{ $('Config').first().json.cfg.developer.model }}` |
| Chat Model -> Temperature (Options) | `{{ $('Config').first().json.cfg.developer.temperature }}` |

Use the keys `product_manager`, `architect`, `developer`, `tester`. For the Product Manager, set the prompt to *Define below* with `{{ $('Config').first().json.request }}`.

The page edits the model **name**; the provider (Gemini or Anthropic) stays whatever node you attached.

**d) Log every step.** After each agent add **Supabase -> Create a row** (table `run_steps`):

| Field | Value |
|---|---|
| run_id | `{{ $('Config').first().json.run_id }}` |
| agent | `product_manager` / `architect` / `developer` / `tester` |
| round | `{{ $runIndex + 1 }}` |
| output | `{{ $('Product Manager').last().json.output }}` (use the agent's own name) |

Chain it as `Agent -> Log node -> next node`. The Tester's log node goes before *Round Counter*. The loop from the If node still goes back to the Developer.

**e) Finish.** After *Final Package* add **Supabase -> Update a row** on table `runs`: filter `id` equals `{{ $('Config').first().json.run_id }}`, set `status` = `done` and `final_output` = `{{ $json.output }}`. The Extract Code, Convert to File and Reply nodes are no longer needed, because the page builds the downloads.

**f) Publish.** Click **Publish** and copy the **Production URL** of the Webhook node.

## 3. Open the page

1. Open `index.html` in your browser (double-click works), or host it on GitHub Pages or Netlify.
2. Enter the Supabase URL, the **anon** key and the n8n webhook URL, then **Save & connect**.
3. Pick an example chip, press **Run**, and watch the pipeline fill in. Edit a prompt on the right, **Save**, and run again to see the difference.

## Notes

- **Keys stay in your browser** (localStorage). Never put the service_role key in the page.
- **The policies in `supabase.sql` are open** for a demo: anyone with your anon key can edit prompts. For real use, add Supabase Auth and tighten the policies.
- **The webhook is public.** Anyone with the URL can start runs that cost tokens. Add Header Auth on the Webhook node for real use.
- **A run that shows `running` forever** means n8n failed. Check n8n -> Executions for the error.
- If Realtime isn't enabled, the page falls back to polling every 3 seconds during a run.
