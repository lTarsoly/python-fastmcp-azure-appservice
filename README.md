# python-fastmcp-azure-appservice

A minimal example FastMCP server built with FastAPI-style tooling and prepared for deployment to Azure App Service.

This repository contains a tiny FastMCP-based Python app (`app.py`), a `requirements.txt` listing runtime dependencies, and a `deploy.ps1` script that provisions an Azure App Service and deploys the app.

## Contents

- `app.py` — example FastMCP application exposing a simple `add` tool and a root health check route.
- `requirements.txt` — Python dependencies needed to run the app.
- `deploy.ps1` — PowerShell script that creates an Azure resource group, App Service plan and Web App, configures startup, packages the app, and deploys it.

## Quick contract

- Inputs: HTTP requests to the web server (tool calls or HTTP GET to `/`).
- Outputs: JSON responses; e.g. health check returns `{ "status": "server running" }` and tool calls return tool-specific results.
- Error modes: missing dependencies or misconfigured environment will prevent the process from starting; Azure deployment errors will be surfaced by the Azure CLI.

## Requirements

- Python 3.11+ (the Azure runtime in `deploy.ps1` is set to use Python 3.13; locally, 3.11+ is recommended).
- `pip` and virtual environment support.
- (For deployment) Azure CLI installed and authenticated.

## Setup (local)

1. Create and activate a virtual environment in the repository root:

	PowerShell:

	```powershell
	python -m venv .venv
	.\.venv\Scripts\Activate.ps1
	```

	(On macOS / Linux use `python -m venv .venv` then `source .venv/bin/activate`.)

2. Install dependencies:

	```powershell
	python -m pip install --upgrade pip
	python -m pip install -r requirements.txt
	```

3. Run the app locally:

	```powershell
	python app.py
	```

	The server listens on 0.0.0.0:8000 by default. Visit http://localhost:8000/ to see the health check JSON.

## Example usage

- Health check (browser or curl):

  ```powershell
  curl http://localhost:8000/
  # -> { "status": "server running" }
  ```

- Tool example (programmatic): the repository exposes a tool named `add(a: int, b: int) -> int` which returns the sum of two integers. How you invoke FastMCP tools depends on your client; consult the FastMCP client docs for calling server-side tools.

## Deploy to Azure App Service (PowerShell)

The included `deploy.ps1` script automates creation of resources and deployment. It assumes you have the Azure CLI installed and are logged in.

1. Ensure Azure CLI is installed and you are logged in:

	```powershell
	az login
	```

2. Prepare a virtual environment and install dependencies (see Setup above). The deployment script packages the `.venv` folder, so creating `.venv` prior to deployment is required by the script as currently written.

3. Run the deployment script from the repository root in PowerShell:

	```powershell
	.\deploy.ps1
	```

The script will:

- create an Azure resource group, App Service plan, and Web App (runtime set to `PYTHON:3.13`),
- configure the web app to run `python app.py` as its startup command,
- zip your `.venv`, `app.py`, and `requirements.txt` and deploy them to the web app.

Notes:
- Adjust resource names and location in `deploy.ps1` as needed for your subscription and naming policies.
- Packaging `.venv` is convenient but not mandatory; you can instead rely on App Service to build from `requirements.txt` by changing the script and enabling build-on-deploy.

## Troubleshooting

- If the app fails to start locally, check that dependencies from `requirements.txt` installed successfully and that you used the correct Python version.
- For deployment, inspect the App Service logs in the Azure portal or run the following to stream logs:

  ```powershell
  az webapp log tail --resource-group LaszlosPythonWebAppResourceGroup --name LaszlosPythonWebApp
  ```

- If the web app reports missing packages, consider switching the deployment approach to let App Service build from `requirements.txt` rather than deploying `.venv`.

## Contributing

Small, focused contributions are welcome. Open an issue or a PR with a clear description of the change.

## License

This repository has no license file by default. Add a `LICENSE` file if you plan to open-source the code.

## Contact

Project owner: Laszlo (repository owner `lTarsoly`)

---

If you'd like, I can also:

- add a minimal `Makefile` or `tasks.json` for common tasks (run, test, deploy),
- modify `deploy.ps1` to not depend on `.venv` and instead use App Service build-from-requirements,
- add a small test that starts `app.py` and checks the health endpoint programmatically.