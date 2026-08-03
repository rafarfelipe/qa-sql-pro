-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 08 - Manipulação de Dados para Testes
-- AULA  : 41 - Transações: BEGIN, COMMIT e ROLLBACK
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a usar transações para controlar alterações no banco.
--   Para QAs, isso é essencial para:
--   - Testar regras de negócio sem sujar o banco
--   - Validar dados antes de salvar
--   - Desfazer alterações quando algo dá errado
-- ============================================================
-- TABELAS UTILIZADAS:
--   - categories, products
-- ============================================================

-- ⚠️ ANTES DE COMEÇAR:
-- Desabilite o AUTO-COMMIT no DBeaver
-- Ou: SQL Editor → Auto-commit → desabilita

-- -----------------------------------------------
-- EXEMPLO 1 — COMMIT: Salvando a alteração
-- -----------------------------------------------

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


-- -----------------------------------------------
-- EXEMPLO 2 — ROLLBACK: Desfazendo a alteração
-- -----------------------------------------------

BEGIN;

SELECT id, name, is_active
FROM categories
WHERE id = 10;

UPDATE categories
SET is_active = TRUE, created_at = now()
WHERE id = 10;

SELECT id, name, is_active
FROM categories
WHERE id = 10;

ROLLBACK;

SELECT id, name, is_active
FROM categories
WHERE id = 10;


-- -----------------------------------------------
-- EXEMPLO 3 — Múltiplas Operações com ROLLBACK
-- -----------------------------------------------

BEGIN;

-- Verifica os dados antes
SELECT id, name, is_active FROM categories WHERE name LIKE 'Teste%';
SELECT id, name, price FROM products WHERE id = 848;
SELECT id, name, is_active FROM categories WHERE id = 15;

-- Insere uma nova categoria
INSERT INTO categories
(name, slug, description, is_active, created_at)
VALUES
('Categoria Transação', 'categoria-transacao', 'Criada em transação com múltiplas operações', TRUE, now());

-- Atualiza o preço de um produto
UPDATE products
SET price = 1000, created_at = now()
WHERE id = 848;

-- Deleta uma categoria antiga (se existir)
DELETE FROM categories
WHERE id = 86;

-- Verifica tudo dentro da transação
SELECT id, name, is_active FROM categories WHERE slug = 'categoria-transacao';
SELECT id, name, price FROM products WHERE id = 848;

-- Desfaz tudo
ROLLBACK;

-- Confirma que nada foi salvo
SELECT id, name, is_active FROM categories WHERE slug = 'categoria-transacao';
SELECT id, name, price FROM products WHERE id = 848;


-- ============================================================
-- RESUMO DA AULA:
--   BEGIN    → Inicia uma transação
--   COMMIT   → Salva todas as alterações permanentemente
--   ROLLBACK → Desfaz todas as alterações
--   
--   DICA DE OURO:
--   1. Execute LINHA POR LINHA
--   2. SEMPRE confirme com SELECT
--   3. Se der erro → ROLLBACK
--   4. Se tá certo → COMMIT
--   5. Desabilite o AUTO-COMMIT no DBeaver!
--   
--   🎯 PARA QA: USE SEMPRE BEGIN + ROLLBACK PARA TESTES!
-- ============================================================