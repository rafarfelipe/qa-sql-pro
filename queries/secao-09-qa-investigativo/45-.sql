-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 45 - DISTINCT: encontrando duplicidade de dados
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a usar DISTINCT para encontrar duplicidades de dados.
--   Para QAs, isso é essencial para validar se campos que deveriam
--   ser únicos realmente são.
-- ============================================================


-- -----------------------------------------------
-- BLOCO 1 — DISTINCT: Listando valores únicos
-- -----------------------------------------------

-- Listando todas as categorias (com duplicidade)
SELECT category_id FROM products;

-- Listando apenas valores únicos
SELECT DISTINCT category_id FROM products;


-- -----------------------------------------------
-- BLOCO 2 — GROUP BY: Contando por categoria
-- -----------------------------------------------

-- Para saber a quantidade de produtos por categoria
SELECT 
    category_id,
    COUNT(*) AS quantidade
FROM products
GROUP BY category_id
ORDER BY quantidade DESC;


-- -----------------------------------------------
-- BLOCO 3 — Correção: Produtos sem Categoria
-- -----------------------------------------------

-- Deleta produtos sem categoria
DELETE FROM products WHERE category_id IS NULL;


-- -----------------------------------------------
-- BLOCO 4 — Investigação: Nomes Duplicados
-- -----------------------------------------------

-- Detectando nomes duplicados
SELECT
    name,
    COUNT(*) AS quantidade
FROM products
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;


-- ============================================================
-- RESUMO DA AULA:
--   DISTINCT → Lista valores únicos
--   GROUP BY + COUNT → Conta quantos por grupo
--   HAVING COUNT(*) > 1 → Encontra duplicados
--   
--   Dica de QA → Sempre confirme com SELECT antes de DELETE
-- ============================================================