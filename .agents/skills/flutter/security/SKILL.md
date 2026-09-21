---
name: security
description: Apply practical mobile security to company base-flutter projects. Use when handling authentication, storage, secrets, Dio logging, release builds, PII, token refresh, or security-sensitive features.
---

# Flutter Security

Read `../company-base-flutter/SKILL.md` first.

- Never hardcode secrets, credentials, signing material, or production tokens.
- Use shared preferences only for non-sensitive preferences/cache; store real access/refresh tokens and sensitive PII in platform-backed secure storage.
- Redact authorization headers, passwords, tokens, and PII from logs.
- Preserve release obfuscation and symbol outputs; validate product-specific signing/vault assumptions separately.
- Add certificate pinning, root detection, or anti-tamper controls only when the product threat model requires them.
- Keep security dependencies behind injected services; do not hide them in extensions or global helpers.
