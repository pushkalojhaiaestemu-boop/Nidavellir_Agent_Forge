# AgentForge setup

Get the API and the UI running on your machine in about five minutes. No API key is needed for the first run.

## What you need

- Python 3.11 or newer
- Node.js 20 or newer
- Git (optional; when present the agents commit the starting state and report a real `git diff`)

## 1. Start the API

```bash
cd backend
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
uvicorn app.main:app --reload --port 8000
```

Check it: open <http://localhost:8000/api/health>. You should see `"status": "ready"`.

## 2. Start the UI

In a second terminal:

```bash
cd frontend
cp .env.local.example .env.local
npm install
npm run dev
```

Open <http://localhost:3000>.

## 3. Run your first task

1. In the repository panel, load the bundled sample: the path field is pre-filled with `../sample_repo`. You can also upload a `.zip` of your own repository.
2. Pick a sample task, for example "Add JWT authentication", and start it.
3. Watch the agents plan, edit, test and verify. The diff and report appear when the run finishes.

Prefer the terminal? From the project root:

```bash
make demo-bug
```

This breaks the sample repository on purpose and lets the tester and fixer agents repair it.

## Turn on a real model (optional)

Out of the box the agents run in deterministic mode with no model. To use one, set these variables in the terminal that starts the API. The backend reads real environment variables; it does not load a `.env` file by itself.

```bash
export LLM_PROVIDER=anthropic       # or: openai
export LLM_API_KEY=your-key
export LLM_MODEL=claude-sonnet-4-5
```

To keep them in a file instead, copy `backend/.env.example` to `backend/.env`, fill it in, and load it before starting:

```bash
set -a; source .env; set +a
```

## Settings worth knowing

| Variable | Default | What it does |
|---|---|---|
| `SANDBOX_BACKEND` | `subprocess` | Set to `docker` to run repository tests in a throwaway container with no network. Recommended for any repository you do not trust. |
| `APPROVAL_MODE` | `false` | Set to `true` to make the run pause for your approval before changes are finalised. |
| `GRAPH_BACKEND` | `memory` | Set to `neo4j` to store the code graph in Neo4j (see below). |
| `MAX_FIX_ITERATIONS` | `3` | How many times the fixer may retry a failing suite. |
| `CORS_ORIGINS` | `http://localhost:3000` | Comma-separated list of origins allowed to call the API. |

## Run everything with Docker (optional)

```bash
docker compose up --build
```

This starts Neo4j (7474, 7687), the API (8000) and the UI (3000).

## Run the tests

```bash
cd backend
python -m pytest -q
```

## If something goes wrong

| Symptom | Fix |
|---|---|
| UI shows "cannot reach API" | Confirm the API is on port 8000 and `frontend/.env.local` has `NEXT_PUBLIC_API_URL=http://localhost:8000`. |
| Upload rejected with 413 | The archive is over 100 MB. Zip only the source, without `node_modules` or virtual environments. |
| "No supported source files found" | AgentForge parses Python, JavaScript and TypeScript. Point it at a repository that contains one of them. |
| Test run reports "pytest is not installed" | Install the target repository's test dependencies into the same virtual environment as the API. |
| Docker sandbox requested but tests still run locally | Docker was not found on `PATH`, so the API fell back to the subprocess sandbox. Install Docker and restart. |

More detail: [README.md](README.md), [docs/ENGINEERING.md](docs/ENGINEERING.md), [docs/security-model.md](docs/security-model.md).
