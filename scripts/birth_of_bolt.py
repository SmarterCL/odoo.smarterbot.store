#!/usr/bin/env python3
"""
Birth of Bolt - SmarterOS Documentation Generator
==================================================

Purpose:
    Generate comprehensive documentation for SmarterOS using AI agents.
    This script reads system specifications and produces:
    - User guides
    - API documentation
    - Integration guides
    - Troubleshooting docs
    - Partner onboarding materials

Prerequisites:
    - /specs/versions.lock
    - /specs/os.md
    - /specs/BRANDING.md
    - OPENAI_API_KEY environment variable

Output:
    - /docs/*.md (generated documentation)
    - Validation report
    - BOLT PASS/FAIL status

Author: SmarterOS Team
Version: 1.0.0
Date: 2025-11-23
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
from openai import OpenAI

# Configuration
SPECS_DIR = Path("/root/smarteros/specs")
DOCS_DIR = Path("/root/smarteros/docs")
OPENAI_MODEL = "gpt-4-turbo-preview"
MAX_TOKENS = 4000

# Ensure docs directory exists
DOCS_DIR.mkdir(parents=True, exist_ok=True)


class BoltGenerator:
    """Main documentation generator for SmarterOS"""

    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")
        if not self.api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set")
        
        self.client = OpenAI(api_key=self.api_key)
        self.specs = {}
        self.results = {
            "generated": [],
            "failed": [],
            "timestamp": datetime.utcnow().isoformat()
        }

    def load_specs(self) -> bool:
        """Load all specification files"""
        print("📖 Loading specifications...")
        
        required_files = ["versions.lock", "os.md", "BRANDING.md"]
        
        for filename in required_files:
            filepath = SPECS_DIR / filename
            if not filepath.exists():
                print(f"❌ Missing required file: {filename}")
                return False
            
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
                self.specs[filename] = content
                print(f"   ✅ Loaded {filename} ({len(content)} chars)")
        
        print("✅ All specifications loaded\n")
        return True

    def generate_document(
        self, 
        doc_type: str, 
        output_filename: str,
        system_prompt: str,
        user_prompt: str
    ) -> bool:
        """Generate a single documentation file using OpenAI"""
        
        print(f"📝 Generating {doc_type}...")
        
        try:
            response = self.client.chat.completions.create(
                model=OPENAI_MODEL,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                max_tokens=MAX_TOKENS,
                temperature=0.7
            )
            
            content = response.choices[0].message.content
            
            # Write to file
            output_path = DOCS_DIR / output_filename
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(content)
            
            print(f"   ✅ Generated {output_filename} ({len(content)} chars)\n")
            self.results["generated"].append(output_filename)
            return True
            
        except Exception as e:
            print(f"   ❌ Failed to generate {output_filename}: {str(e)}\n")
            self.results["failed"].append({"file": output_filename, "error": str(e)})
            return False

    def generate_getting_started(self) -> bool:
        """Generate getting started guide"""
        
        system_prompt = """You are a technical writer creating clear, actionable documentation 
        for SmarterOS - a containerized business automation operating system. Write in a friendly 
        but professional tone. Include code examples and commands."""
        
        user_prompt = f"""Based on these specifications, create a comprehensive "Getting Started" 
        guide for new users of SmarterOS:

        {self.specs['os.md']}
        
        {self.specs['versions.lock']}
        
        The guide should include:
        1. Prerequisites
        2. Installation steps
        3. First login and setup
        4. Basic configuration
        5. Verifying the installation
        6. Next steps
        
        Format: Markdown with clear headings, code blocks, and examples."""
        
        return self.generate_document(
            "Getting Started Guide",
            "getting-started.md",
            system_prompt,
            user_prompt
        )

    def generate_api_reference(self) -> bool:
        """Generate API reference documentation"""
        
        system_prompt = """You are an API documentation specialist. Create clear, precise 
        API documentation with examples, request/response formats, and authentication details."""
        
        user_prompt = f"""Based on these specifications, create comprehensive API reference 
        documentation for the SmarterOS API:

        {self.specs['os.md']}
        
        Focus on:
        1. Authentication methods
        2. All available endpoints by category (core, odoo, supabase, n8n, chatwoot)
        3. Request/response examples for each endpoint
        4. Error handling
        5. Rate limiting
        6. MCP registry integration
        
        Include curl examples and response formats.
        Format: Markdown with clear sections and code blocks."""
        
        return self.generate_document(
            "API Reference",
            "api-reference.md",
            system_prompt,
            user_prompt
        )

    def generate_integration_guide(self) -> bool:
        """Generate integration guides for external services"""
        
        system_prompt = """You are a solutions architect writing integration guides. 
        Focus on practical, step-by-step instructions with real-world examples."""
        
        user_prompt = f"""Based on these specifications, create integration guides 
        for connecting external services to SmarterOS:

        {self.specs['os.md']}
        
        {self.specs['BRANDING.md']}
        
        Cover:
        1. Odoo ERP integration
        2. Supabase database setup
        3. n8n workflow automation
        4. Chatwoot CRM connection
        5. Payment gateway integration (conceptual)
        6. Custom MCP tools creation
        
        Include configuration examples and troubleshooting tips.
        Format: Markdown with clear sections."""
        
        return self.generate_document(
            "Integration Guide",
            "integrations.md",
            system_prompt,
            user_prompt
        )

    def generate_partner_guide(self) -> bool:
        """Generate partner onboarding documentation"""
        
        system_prompt = """You are a business development specialist writing partner 
        onboarding materials. Be professional, clear about benefits, and action-oriented."""
        
        user_prompt = f"""Based on these specifications, create a partner onboarding guide 
        for the SmarterBot partner program:

        {self.specs['BRANDING.md']}
        
        Cover:
        1. Partner program overview
        2. Certification tiers and benefits
        3. Technical requirements
        4. Revenue sharing model
        5. Marketing resources
        6. Support and training
        7. How to get started
        
        Format: Markdown with clear value propositions and action steps."""
        
        return self.generate_document(
            "Partner Guide",
            "partner-guide.md",
            system_prompt,
            user_prompt
        )

    def generate_troubleshooting(self) -> bool:
        """Generate troubleshooting documentation"""
        
        system_prompt = """You are a support engineer writing troubleshooting guides. 
        Anticipate common problems and provide clear solutions with diagnostic steps."""
        
        user_prompt = f"""Based on these specifications, create a troubleshooting guide 
        for SmarterOS:

        {self.specs['os.md']}
        
        {self.specs['versions.lock']}
        
        Include:
        1. Common installation issues
        2. Container startup problems
        3. API connectivity issues
        4. Database connection errors
        5. SSL/certificate problems
        6. Performance optimization
        7. Diagnostic commands
        8. Where to get help
        
        Format: Markdown with problem/solution pairs and command examples."""
        
        return self.generate_document(
            "Troubleshooting Guide",
            "troubleshooting.md",
            system_prompt,
            user_prompt
        )

    def generate_architecture_overview(self) -> bool:
        """Generate system architecture documentation"""
        
        system_prompt = """You are a system architect creating technical architecture 
        documentation. Be precise, use technical terminology correctly, and explain design decisions."""
        
        user_prompt = f"""Based on these specifications, create an architecture overview 
        for SmarterOS:

        {self.specs['os.md']}
        
        {self.specs['BRANDING.md']}
        
        {self.specs['versions.lock']}
        
        Cover:
        1. High-level system design
        2. Container architecture
        3. Network topology
        4. Data flow diagrams (in text/mermaid)
        5. Security model
        6. Scalability considerations
        7. Technology stack justification
        
        Format: Markdown with technical depth appropriate for engineers."""
        
        return self.generate_document(
            "Architecture Overview",
            "architecture.md",
            system_prompt,
            user_prompt
        )

    def validate_output(self) -> bool:
        """Validate generated documentation"""
        print("🔍 Validating generated documentation...\n")
        
        required_docs = [
            "getting-started.md",
            "api-reference.md",
            "integrations.md",
            "partner-guide.md",
            "troubleshooting.md",
            "architecture.md"
        ]
        
        all_valid = True
        
        for doc in required_docs:
            filepath = DOCS_DIR / doc
            if not filepath.exists():
                print(f"   ❌ Missing: {doc}")
                all_valid = False
                continue
            
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            
            # Basic validation
            if len(content) < 1000:
                print(f"   ⚠️  {doc} seems too short ({len(content)} chars)")
                all_valid = False
            elif not content.startswith("#"):
                print(f"   ⚠️  {doc} doesn't start with a heading")
                all_valid = False
            else:
                print(f"   ✅ {doc} validated ({len(content)} chars)")
        
        return all_valid

    def save_report(self):
        """Save generation report"""
        report_path = DOCS_DIR / "generation-report.json"
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(self.results, f, indent=2)
        print(f"\n📊 Report saved to {report_path}")

    def run(self) -> bool:
        """Main execution flow"""
        print("=" * 60)
        print("🚀 BIRTH OF BOLT - Documentation Generator")
        print("=" * 60)
        print()
        
        # Load specs
        if not self.load_specs():
            print("❌ BOLT FAIL - Missing specifications\n")
            return False
        
        # Generate all documents
        generators = [
            self.generate_getting_started,
            self.generate_api_reference,
            self.generate_integration_guide,
            self.generate_partner_guide,
            self.generate_troubleshooting,
            self.generate_architecture_overview
        ]
        
        for generator in generators:
            if not generator():
                print(f"⚠️  Warning: {generator.__name__} failed, continuing...\n")
        
        # Validate
        validation_passed = self.validate_output()
        
        # Save report
        self.save_report()
        
        # Final verdict
        print("\n" + "=" * 60)
        if validation_passed and len(self.results["generated"]) >= 5:
            print("✅ BOLT PASS - Documentation generated successfully")
            print("=" * 60)
            print(f"\n📁 Generated {len(self.results['generated'])} documents in {DOCS_DIR}")
            return True
        else:
            print("❌ BOLT FAIL - Documentation generation incomplete")
            print("=" * 60)
            print(f"\n⚠️  Generated: {len(self.results['generated'])}")
            print(f"⚠️  Failed: {len(self.results['failed'])}")
            return False


def main():
    """Entry point"""
    try:
        generator = BoltGenerator()
        success = generator.run()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n💥 FATAL ERROR: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
