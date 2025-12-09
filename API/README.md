# Allergen Checker API (uv + FastAPI)

This is the FastAPI backend for Allergen Checker, migrated to a modern uv + pyproject setup with a src/ layout.

## Layout

- `pyproject.toml` – project metadata and dependencies
- `src/app/` – Python package
  - `main.py` – FastAPI app
  - `ai/` – AI helpers
  - `data/` – database models and SQLite implementation
  - `ocr/` – AWS Textract OCR integration
  - `banned_words.txt` – filtering list

## Quick start

- Install uv: https://github.com/astral-sh/uv
- Run the API:

```bash
# from the API folder
uv run --python 3.12 --with uvicorn uvicorn app.main:app --host 0.0.0.0 --port 8000 --env-file ../.env --reload
```

Or use the helper script:

```bash
./run.sh
```

## Environment

- OPEN_AI_TOKEN – OpenAI API key used by `app.ai.open_ai_checker`

## Notes

- SQLite DB lives at `src/app/data/database_files/allergens.sqlite`.
- If you bundle this app, ensure `PYTHONPATH` includes `src`.
