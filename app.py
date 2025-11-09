from fastmcp import FastMCP
from fastapi import Request, Response
from fastapi.responses import JSONResponse

# Create a server instance with a descriptive name
app = FastMCP(name="Laszlos First MCP Server")

@app.tool
def add(a: int, b: int) -> int:
    """Adds two integer numbers together."""
    return a + b

@app.custom_route("/", methods=["GET"])
async def health_check(request: Request) -> Response:
    return JSONResponse({"status": "server running"})

if __name__ == "__main__":
    app.run(transport="http", host="0.0.0.0", port=8000)