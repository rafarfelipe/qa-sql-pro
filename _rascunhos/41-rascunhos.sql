BEGIN;

SELECT id, name, is_active
FROM categories
WHERE id = 10;

UPDATE categories
SET is_active = FALSE, created_at = now()
WHERE id = 10;

SELECT id, name, is_active
FROM categories
WHERE id = 10;

COMMIT;

ROLLBACK;

----------------------------------------------------
-- ============================================================
-- EXEMPLO 4 — Múltiplas Operações em uma Transação
-- ============================================================

-- 1. Inicia a transação
BEGIN;

-- 2. Verifica os dados antes
SELECT id, name, is_active FROM categories WHERE name LIKE 'Teste%';
SELECT id, name, price FROM products WHERE id = 848;
SELECT id, name, is_active FROM categories WHERE id = 15;

-- 3. Insere uma nova categoria
INSERT INTO categories
(name, slug, description, is_active, created_at)
VALUES
('Categoria Transação', 'categoria-transacao', 'Criada em transação com múltiplas operações', TRUE, now());

-- 4. Atualiza o preço de um produto
UPDATE products
SET price = 1000, created_at = now()
WHERE id = 848;

-- 5. Deleta uma categoria antiga (se existir)
DELETE FROM categories
WHERE id = 86;

-- 7. Desfaz tudo (ROLLBACK)
ROLLBACK;

-- 8. Confirma que nada foi salvo
SELECT id, name, is_active FROM categories WHERE slug = 'categoria-transacao';
SELECT id, name, price FROM products WHERE id = 848;
