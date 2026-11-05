# User Taste
- Communicates in Spanish and expects responses in Spanish. Confidence: 0.8
- Bootstraps sessions by pointing the agent at a `context.md` file (e.g. "lee @context.md y adquiere el contexto") and expects the agent to read it and internalize the project context before starting work. Confidence: 0.6
- For academic writing (thesis work): only use reliable academic sources with full text available — never include sources where only the abstract is accessible, and never cite based solely on the abstract. Confidence: 0.9
- When doing academic writing, report in chat which specific parts of the consulted sources are being referenced/cited. Confidence: 0.85
- Academic writing should be concrete, not "vague"; when a section has guidance from multiple sources (e.g. a reference thesis's structure and a chosen methodology like DSRM), explicitly reconcile the expectations of both rather than following one blindly. Confidence: 0.85
- Respects already-finalized work: instructs not to modify sections that were already updated (e.g. "los objetivos ya fueron actualizados, no deben ser modificados") — scope edits strictly to what was asked. Confidence: 0.75
- Drives long multi-phase tasks with short imperative prompts like "continúa", expecting the agent to resume the in-progress work autonomously without restating context or re-asking questions. Confidence: 0.7
