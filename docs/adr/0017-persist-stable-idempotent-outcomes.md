# Persist Stable Idempotent Outcomes

An Idempotency Key is consumed by accepted outcomes and stable business rejections reached during authoritative evaluation, so later retries return the same result even when Account state changes. Malformed requests, authentication or authorization failures, and temporary unavailability do not consume the key because no valid authoritative operation was decided.
