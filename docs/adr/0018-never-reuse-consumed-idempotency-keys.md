# Never Reuse Consumed Idempotency Keys

A consumed Idempotency Key remains bound to its original operation content and outcome within its namespace for at least the financial-record retention period. It cannot later identify new work, preventing delayed retries from creating duplicate financial activity after an arbitrary expiration window.
