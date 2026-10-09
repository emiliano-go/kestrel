-- Remove the 1px border around the slurp region selection used by recordings, OCR, and QR capture.
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })

-- Keep the satty annotation overlay immediate and out of screen shares.
hl.layer_rule({ match = { namespace = "^satty$" }, no_anim = true, animation = "none", no_screen_share = true })
