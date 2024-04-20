# Make sure we are in the pipenv
pipenv shell

# open the browser
start http://127.0.0.1:8000

# Run in local mode
uvicorn app.main:app --host 0.0.0.0 --port 80 --reload