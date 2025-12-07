"""
Bolt Agent - AI Documentation Generator
========================================

Implements Bolt as an MCP agent with multiple tools.
"""

from typing import Dict, Any, List
from openai import OpenAI
import os
import structlog

logger = structlog.get_logger()

class BoltAgent:
    """Bolt AI Agent for documentation generation"""
    
    def __init__(self):
        self.id = "bolt"
        self.type = "documentation_generator"
        self.version = "1.0.0"
        self.status = "operational"
        self.tools = [
            "bolt.writer",
            "bolt.spec.generator",
            "bolt.docs.generator",
            "bolt.autofix"
        ]
        
        # Initialize OpenAI client
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            logger.warning("openai_api_key_not_set")
            self.client = None
        else:
            self.client = OpenAI(api_key=api_key)
    
    async def invoke(self, tool: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Invoke a Bolt tool
        
        Args:
            tool: Tool name (e.g., "bolt.writer")
            params: Tool parameters
            
        Returns:
            Tool execution result
        """
        logger.info("bolt_tool_invoked", tool=tool)
        
        if tool == "bolt.writer":
            return await self.generate_document(params)
        elif tool == "bolt.spec.generator":
            return await self.generate_spec(params)
        elif tool == "bolt.docs.generator":
            return await self.generate_docs_suite(params)
        elif tool == "bolt.autofix":
            return await self.autofix(params)
        else:
            raise ValueError(f"Unknown tool: {tool}")
    
    async def generate_document(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate a single document"""
        doc_type = params.get("doc_type")
        specs = params.get("specs")
        output_format = params.get("output_format", "markdown")
        
        if not self.client:
            return {
                "status": "error",
                "error": "OpenAI API key not configured"
            }
        
        prompt = f"""Generate a {doc_type} document based on the following specifications:

{specs}

Format: {output_format}
"""
        
        response = self.client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[
                {"role": "system", "content": "You are a technical documentation expert."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=4000
        )
        
        content = response.choices[0].message.content
        
        return {
            "status": "success",
            "doc_type": doc_type,
            "content": content,
            "format": output_format,
            "length": len(content)
        }
    
    async def generate_spec(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate technical specification"""
        service_name = params.get("service_name")
        components = params.get("components", [])
        arch_type = params.get("architecture_type", "microservices")
        
        if not self.client:
            return {"status": "error", "error": "OpenAI API key not configured"}
        
        prompt = f"""Generate a technical specification for:

Service: {service_name}
Architecture: {arch_type}
Components: {', '.join(components)}

Include: System overview, component details, data flow, API specs, deployment.
"""
        
        response = self.client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[
                {"role": "system", "content": "You are a software architect and technical writer."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=4000
        )
        
        return {
            "status": "success",
            "service": service_name,
            "spec": response.choices[0].message.content
        }
    
    async def generate_docs_suite(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Generate complete documentation suite"""
        project = params.get("project")
        include = params.get("include", ["api", "user-guide", "architecture"])
        
        results = {}
        for doc_type in include:
            result = await self.generate_document({
                "doc_type": doc_type,
                "specs": {"project": project},
                "output_format": "markdown"
            })
            results[doc_type] = result
        
        return {
            "status": "success",
            "project": project,
            "documents": results
        }
    
    async def autofix(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Auto-fix code or documentation issues"""
        target = params.get("target")
        issue_type = params.get("issue_type")
        
        if not self.client:
            return {"status": "error", "error": "OpenAI API key not configured"}
        
        prompt = f"""Fix the following {issue_type} issue in:

{target}

Provide the corrected version.
"""
        
        response = self.client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[
                {"role": "system", "content": "You are an expert code reviewer and fixer."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=2000
        )
        
        return {
            "status": "success",
            "issue_type": issue_type,
            "fixed": response.choices[0].message.content
        }

# Singleton instance
bolt_agent = BoltAgent()
