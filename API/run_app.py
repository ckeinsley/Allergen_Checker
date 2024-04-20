import subprocess

def restart_app():
    app_name = 'app.main'  # Replace with your actual app name
    host = '127.0.0.1'  # Specify the desired host (e.g., '0.0.0.0' for all interfaces)
    port = 8000  # Specify the desired port (e.g., 8000)

    # Stop the existing Uvicorn process
    try:
        subprocess.run(['pkill', '-f', app_name], check=True)
        print(f"Stopped {app_name} successfully.")
    except subprocess.CalledProcessError:
        print(f"Failed to stop {app_name}.")

    # Start the Uvicorn process again
    try:
        # Redirect stdout and stderr to files
        with open('stdout.log', 'w') as stdout_file, open('stderr.log', 'w') as stderr_file:
            subprocess.run(['uvicorn', f'{app_name}:app', '--host', host, '--port', str(port)],
                           check=True, stdout=stdout_file, stderr=stderr_file)
        print(f"Restarted {app_name} successfully. Check stdout.log and stderr.log for logs.")
    except subprocess.CalledProcessError:
        print(f"Failed to restart {app_name}.")

if __name__ == '__main__':
    restart_app()