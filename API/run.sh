# pipenv run uvicorn app.main:app --host 0.0.0.0 --port 80 --reload
pipenv install
pipenv run uvicorn app.main:app --host 127.0.0.1 --port 8000