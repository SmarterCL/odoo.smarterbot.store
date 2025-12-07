"""
Nexa Runtime Multi-Tenant Server
OpenAI-compatible API wrapper for Nexa SDK with Vault integration
"""
import os
import logging
from typing import Optional, Dict, Any
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Header, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
import hvac

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


# ==================== Configuration ====================

class Config:
    """Application configuration from environment"""
    NEXA_MODEL_ID = os.getenv("NEXA_MODEL_ID", "llama-3-8b-instruct")
    NEXA_MODEL_STORE = os.getenv("NEXA_MODEL_STORE", "/models")
    NEXA_PORT = int(os.getenv("NEXA_PORT", "8080"))
    NEXA_LOG_LEVEL = os.getenv("NEXA_LOG_LEVEL", "info")
    
    TENANT_MODE = os.getenv("TENANT_MODE", "multi")
    DEFAULT_TENANT_ID = os.getenv("DEFAULT_TENANT_ID", "demo")
    
    VAULT_ADDR = os.getenv("VAULT_ADDR")
    VAULT_TOKEN = os.getenv("VAULT_TOKEN")
    VAULT_NAMESPACE = os.getenv("VAULT_NAMESPACE", "")
    NEXA_VAULT_PATH_TEMPLATE = os.getenv(
        "NEXA_VAULT_PATH_TEMPLATE",
        "secret/data/tenant/{tenant_id}/nexa"
    )


# ==================== Vault Client ====================

class VaultClient:
    """Vault client for fetching tenant secrets"""
    
    def __init__(self):
        self.enabled = bool(Config.VAULT_ADDR and Config.VAULT_TOKEN)
        if self.enabled:
            self.client = hvac.Client(
                url=Config.VAULT_ADDR,
                token=Config.VAULT_TOKEN,
                namespace=Config.VAULT_NAMESPACE or None
            )
            logger.info(f"Vault client initialized: {Config.VAULT_ADDR}")
        else:
            logger.warning("Vault not configured - using defaults")
            self.client = None
    
    def get_tenant_config(self, tenant_id: str) -> Dict[str, Any]:
        """Fetch tenant-specific configuration from Vault"""
        if not self.enabled:
            return self._get_default_config()
        
        try:
            path = Config.NEXA_VAULT_PATH_TEMPLATE.format(tenant_id=tenant_id)
            logger.info(f"Fetching config from Vault: {path}")
            
            response = self.client.secrets.kv.v2.read_secret_version(
                path=path.replace("secret/data/", "")
            )
            
            config = response['data']['data']
            logger.info(f"Config loaded for tenant {tenant_id}")
            return config
            
        except Exception as e:
            logger.error(f"Failed to fetch config for {tenant_id}: {e}")
            return self._get_default_config()
    
    def _get_default_config(self) -> Dict[str, Any]:
        """Default configuration when Vault is unavailable"""
        return {
            "NEXA_MODEL_ID": Config.NEXA_MODEL_ID,
            "NEXA_MAX_CONTEXT_TOKENS": "8192",
            "NEXA_MAX_OUTPUT_TOKENS": "1024",
            "NEXA_TEMPERATURE": "0.7",
            "TENANT_HARD_LIMIT_RPM": "120",
            "TENANT_HARD_LIMIT_CONCURRENCY": "4"
        }


# ==================== Models ====================

class ChatMessage(BaseModel):
    role: str = Field(..., description="Role: system, user, or assistant")
    content: str = Field(..., description="Message content")


class ChatCompletionRequest(BaseModel):
    model: str = Field(default="llama-3-8b-instruct")
    messages: list[ChatMessage]
    temperature: Optional[float] = Field(default=0.7, ge=0.0, le=2.0)
    max_tokens: Optional[int] = Field(default=1024, ge=1, le=8192)
    stream: Optional[bool] = False


class ChatCompletionResponse(BaseModel):
    id: str
    object: str = "chat.completion"
    created: int
    model: str
    choices: list[Dict[str, Any]]
    usage: Dict[str, int]


# ==================== Application ====================

vault_client = VaultClient()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown"""
    logger.info("Starting Nexa Runtime Multi-Tenant Server")
    logger.info(f"Model: {Config.NEXA_MODEL_ID}")
    logger.info(f"Store: {Config.NEXA_MODEL_STORE}")
    logger.info(f"Tenant Mode: {Config.TENANT_MODE}")
    
    # TODO: Initialize Nexa SDK here
    # from nexa.gguf import NexaTextInference
    # app.state.nexa = NexaTextInference(model_path=Config.NEXA_MODEL_ID)
    
    yield
    
    logger.info("Shutting down Nexa Runtime")
    # Cleanup if needed


app = FastAPI(
    title="Nexa Runtime Multi-Tenant API",
    description="OpenAI-compatible API for Nexa SDK with multi-tenant support",
    version="0.1.0",
    lifespan=lifespan
)


# ==================== Middleware ====================

@app.middleware("http")
async def tenant_resolver_middleware(request: Request, call_next):
    """Resolve tenant ID from headers"""
    tenant_id = request.headers.get("X-Tenant-Id", Config.DEFAULT_TENANT_ID)
    request.state.tenant_id = tenant_id
    request.state.tenant_config = vault_client.get_tenant_config(tenant_id)
    
    response = await call_next(request)
    response.headers["X-Tenant-Id"] = tenant_id
    return response


# ==================== Endpoints ====================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "nexa-runtime",
        "version": "0.1.0",
        "model": Config.NEXA_MODEL_ID,
        "vault_enabled": vault_client.enabled
    }


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Nexa Runtime Multi-Tenant API",
        "version": "0.1.0",
        "docs": "/docs",
        "health": "/health",
        "endpoints": {
            "chat": "/v1/chat/completions",
            "embeddings": "/v1/embeddings"
        }
    }


@app.post("/v1/chat/completions", response_model=ChatCompletionResponse)
async def chat_completions(
    request: ChatCompletionRequest,
    req: Request,
    x_tenant_id: Optional[str] = Header(None, alias="X-Tenant-Id")
):
    """
    OpenAI-compatible chat completions endpoint
    Uses Nexa SDK for inference
    """
    tenant_id = req.state.tenant_id
    tenant_config = req.state.tenant_config
    
    logger.info(f"Chat completion request for tenant: {tenant_id}")
    logger.info(f"Model: {request.model}, Messages: {len(request.messages)}")
    
    try:
        # TODO: Replace with actual Nexa SDK inference
        # For now, return a mock response
        
        # Example of how to use Nexa SDK:
        # from nexa.gguf import NexaTextInference
        # nexa = NexaTextInference(model_path=request.model)
        # response = nexa.create_completion(
        #     prompt=format_messages(request.messages),
        #     max_tokens=request.max_tokens,
        #     temperature=request.temperature
        # )
        
        # Mock response
        import time
        response_text = f"[Nexa Runtime Mock Response for {tenant_id}] I received your message."
        
        return ChatCompletionResponse(
            id=f"chatcmpl-{int(time.time())}",
            created=int(time.time()),
            model=request.model,
            choices=[{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": response_text
                },
                "finish_reason": "stop"
            }],
            usage={
                "prompt_tokens": sum(len(m.content.split()) for m in request.messages),
                "completion_tokens": len(response_text.split()),
                "total_tokens": sum(len(m.content.split()) for m in request.messages) + len(response_text.split())
            }
        )
        
    except Exception as e:
        logger.error(f"Error in chat completion: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/v1/embeddings")
async def create_embeddings(
    req: Request,
    x_tenant_id: Optional[str] = Header(None, alias="X-Tenant-Id")
):
    """
    OpenAI-compatible embeddings endpoint
    Uses Nexa SDK for embedding generation
    """
    tenant_id = req.state.tenant_id
    
    logger.info(f"Embeddings request for tenant: {tenant_id}")
    
    # TODO: Implement embeddings with Nexa SDK
    raise HTTPException(
        status_code=501,
        detail="Embeddings endpoint not yet implemented"
    )


@app.get("/admin/models")
async def list_models():
    """List available models"""
    return {
        "models": [
            {
                "id": Config.NEXA_MODEL_ID,
                "object": "model",
                "created": 1699561600,
                "owned_by": "nexa"
            }
        ]
    }


@app.get("/admin/tenants/{tenant_id}/config")
async def get_tenant_config(tenant_id: str):
    """Get tenant configuration (admin endpoint)"""
    config = vault_client.get_tenant_config(tenant_id)
    # Mask sensitive values
    return {
        "tenant_id": tenant_id,
        "model": config.get("NEXA_MODEL_ID"),
        "max_context_tokens": config.get("NEXA_MAX_CONTEXT_TOKENS"),
        "max_output_tokens": config.get("NEXA_MAX_OUTPUT_TOKENS"),
        "rate_limits": {
            "rpm": config.get("TENANT_HARD_LIMIT_RPM"),
            "concurrency": config.get("TENANT_HARD_LIMIT_CONCURRENCY")
        }
    }


# ==================== Main ====================

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=Config.NEXA_PORT,
        log_level=Config.NEXA_LOG_LEVEL.lower()
    )
