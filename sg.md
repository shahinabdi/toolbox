Got you, Shahin — now we’re getting into real workflow orchestration, not just automation.

You want two scenarios:

✅ Scenario A — API + Celery (always run)

⚠️ Scenario B — Tests (same directory, same env, same commands)

…but tests should NOT auto‑run, only open the window and prepare it so you can run tests manually when you want.

This is a very common real‑world pattern, and we can implement it cleanly.

Let’s build the correct professional solution.

---

⚡ What You Want (Restated Clearly)

• One script
• Same project directory
• Same env (either .env OR conda env — not both)
• Window 1 → API (auto‑run)
• Window 2 → Celery (auto‑run)
• Window 3 → Tests (open, env ready, but do NOT run pytest)
• Tests window should allow you to type commands manually
• Everything dynamic and reusable


Perfect. Let’s build it.

---

🧩 Final Ultra‑Clean Script (API + Celery auto-run, Tests only prepared)

#!/usr/bin/env bash

SESSION="$1"          # ex: dev
PROJECT_DIR="$2"      # ex: ~/projects/backend

ENV_TYPE="$3"         # "env" or "conda" or "none"
ENV_VALUE="$4"        # ".env" or "myenv" or ""

API_CMD="$5"          # ex: uvicorn app:app --reload
CELERY_CMD="$6"       # ex: celery -A app worker -l info

# Helper: apply environment setup
apply_env() {
    local TARGET="$1"

    tmux send-keys -t "$TARGET" "cd $PROJECT_DIR" Enter

    if [[ "$ENV_TYPE" == "env" ]]; then
        tmux send-keys -t "$TARGET" "source $ENV_VALUE 2>/dev/null || true" Enter
    elif [[ "$ENV_TYPE" == "conda" ]]; then
        tmux send-keys -t "$TARGET" "conda activate $ENV_VALUE 2>/dev/null || true" Enter
    fi
}

# Create session
tmux new-session -d -s "$SESSION" -n api
apply_env "$SESSION:api"
tmux send-keys -t "$SESSION:api" "$API_CMD" Enter

# Celery window
tmux new-window -t "$SESSION" -n celery
apply_env "$SESSION:celery"
tmux send-keys -t "$SESSION:celery" "$CELERY_CMD" Enter

# Tests window (NO auto-run)
tmux new-window -t "$SESSION" -n tests
apply_env "$SESSION:tests"
tmux send-keys -t "$SESSION:tests" "# Ready for tests (pytest not auto-run)" Enter

tmux attach -t "$SESSION"


---

🚀 How to Use It

✔ Using `.env` file

./workspace.sh dev ~/projects/backend env .env \
"uvicorn app:app --reload" \
"celery -A app worker -l info"


✔ Using conda env

./workspace.sh dev ~/projects/backend conda myenv \
"uvicorn app:app --reload" \
"celery -A app worker -l info"


✔ Using no env

./workspace.sh dev ~/projects/backend none "" \
"uvicorn app:app --reload" \
"celery -A app worker -l info"


---

🧠 What Happens Now?

Window 1 → API

• cd project
• env ready
• conda ready
• API auto‑runs


Window 2 → Celery

• cd project
• env ready
• conda ready
• Celery auto‑runs


Window 3 → Tests

• cd project
• env ready
• conda ready
• pytest NOT executed
• You can type:pytest -q
whenever you want.


---

🔥 Why This Is the Correct Professional Pattern

✔ API + Celery take time → auto-run

You don’t want to type them manually every time.

✔ Tests should NOT auto-run

Because:

• sometimes you don’t want to run tests
• sometimes you want to run only one test
• sometimes you want to run tests after API is ready
• sometimes you want to run tests repeatedly


✔ One script → multiple workflows

You don’t need separate scripts.

✔ Clean, modular, elegant

Matches your engineering style.

---

⚡ If you want, I can also add:

• fzf menu to choose which windows to auto-run
• profiles (backend, ML, DevOps, microservices)
• auto-detect env file
• auto-detect conda env
• auto-layout (tiled, main-horizontal, main-vertical)
• logging windows


Just tell me how far you want to take this.