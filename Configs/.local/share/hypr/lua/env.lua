
hyde = hyde or {}
hyde.env.finalize()
hl.env("PATH", (hyde.env("PATH") or "") .. ":" .. hyde.path.lib)
