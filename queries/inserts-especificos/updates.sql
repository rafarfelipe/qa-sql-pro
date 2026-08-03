-- ============================================================
-- UPDATE: Desativando produtos em lote (faixa de IDs)
-- ============================================================

UPDATE public.products
SET 
    is_active = FALSE,
    updated_at = now()
WHERE 
    id BETWEEN 474 AND 635;