.PHONY: install test run-api run-ui demo demo-bug clean

install:
	cd backend && pip install -r requirements.txt
	cd frontend && npm install

test:
	cd backend && python -m unittest discover -s tests

run-api:
	cd backend && uvicorn app.main:app --reload --port 8000

run-ui:
	cd frontend && npm run dev

demo:
	python scripts/run_task.py sample_repo "Add JWT authentication to the user API and protect the /users endpoints." --diff

demo-bug:
	python scripts/inject_bug.py
	python scripts/run_task.py sample_repo_buggy "Find and fix the bug that makes the user service tests fail."

clean:
	rm -rf .agentforge sample_repo_buggy
	find . -name __pycache__ -type d -prune -exec rm -rf {} +
