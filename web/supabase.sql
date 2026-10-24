-- Run in Supabase: SQL Editor -> New query -> paste -> Run. Safe to run more than once.

create table if not exists agent_config (
  agent          text primary key,
  label          text not null,
  system_message text not null,
  model          text not null,
  temperature    numeric not null default 0.3,
  updated_at     timestamptz not null default now()
);

create table if not exists runs (
  id           uuid primary key default gen_random_uuid(),
  request      text not null,
  status       text not null default 'running',   -- running | done | error
  final_output text,
  created_at   timestamptz not null default now()
);

create table if not exists run_steps (
  id         bigint generated always as identity primary key,
  run_id     uuid not null references runs(id) on delete cascade,
  agent      text not null,
  round      int  not null default 1,
  output     text,
  created_at timestamptz not null default now()
);

-- Live updates (Realtime)
do $$
begin
  begin alter publication supabase_realtime add table agent_config; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table runs;         exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table run_steps;    exception when duplicate_object then null; end;
end $$;

-- Access for the web page (anon key). Fine for a class project / demo.
-- Anyone who has the page and your anon key can edit prompts, so do not store secrets here.
alter table agent_config enable row level security;
alter table runs         enable row level security;
alter table run_steps    enable row level security;

drop policy if exists "anon all agent_config" on agent_config;
create policy "anon all agent_config" on agent_config for all to anon using (true) with check (true);
drop policy if exists "anon all runs" on runs;
create policy "anon all runs"         on runs         for all to anon using (true) with check (true);
drop policy if exists "anon all run_steps" on run_steps;
create policy "anon all run_steps"    on run_steps    for all to anon using (true) with check (true);

-- Starter prompts (edit the model names to match the ones your n8n nodes use)
insert into agent_config (agent, label, system_message, model, temperature) values
('product_manager','Product Manager',
$$You are a Product Manager. Turn the user's request into a concise spec with:
1. Goal
2. User stories
3. Acceptance criteria (numbered)
4. Out of scope
Keep it under 300 words. Output only the spec.$$, 'gemini-3.8-flash', 0.3),
('architect','Architect',
$$You are a Software Architect. Design a simple solution with:
1. Programming language and libraries (keep minimal)
2. File structure
3. Function names with a one-line description each
Keep it under 250 words. Output only the design.$$, 'gemini-3.8-flash', 0.3),
('developer','Developer',
$$You are a Senior Python Developer. Write the code for this project.
Rules:
- Write complete, working code. No placeholders.
- Put each file in its own code block, with the file name above it.
- If bugs are listed, fix them without changing unrelated code.
- Output only the code.$$, 'claude-sonnet-5-5', 0.2),
('tester','Tester',
$$You are a QA Engineer. Check the code against the spec. Do these in order:
1. Write 3 to 5 short pytest test cases based on the acceptance criteria.
2. List any bugs you find as a numbered list. If none, write "No bugs found".
3. On the very last line, write exactly one of these:
VERDICT: PASS
VERDICT: FAIL
Write nothing after the VERDICT line.$$, 'claude-sonnet-5-5', 0.2)
on conflict (agent) do nothing;
