-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 07 - SQL Essencial para QA (na prática)
-- AULA  : 36 - Consultas Avançadas (Subqueries)
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a usar subqueries para consultas dentro de consultas.
--   Para QAs, subqueries são úteis para:
--   - Filtrar dados com base em cálculos (ex: acima da média)
--   - Calcular valores adicionais por linha
--   - Verificar existência de registros relacionados
--   - Tratar valores nulos com COALESCE
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products (p), categories (c), reviews (r)
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — Subquery no WHERE
-- -----------------------------------------------

-- 1.1 Calculando a média de preço dos produtos
SELECT AVG(price) FROM products;

-- 1.2 Produtos com preço acima da média
SELECT 
    id,
    name,
    price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 1.3 Produtos mais caros que qualquer produto da categoria 20
SELECT 
    id,
    name,
    price
FROM products
WHERE price > ALL (SELECT price FROM products WHERE category_id = 20)
ORDER BY price DESC;


-- -----------------------------------------------
-- BLOCO 2 — Subquery no SELECT com COALESCE
-- -----------------------------------------------

-- 2.1 Média de avaliações por produto (com NULL)
SELECT 
    p.id,
    p.name AS produto,
    p.price,    
    (SELECT AVG(r.rating) 
     FROM reviews r 
     WHERE r.product_id = p.id) AS media_avaliacao
FROM products p
ORDER BY media_avaliacao DESC;

-- 2.2 Média de avaliações por produto (tratando NULL com COALESCE)
SELECT 
    p.id,
    p.name AS produto,
    p.price,
    COALESCE(
        (SELECT AVG(r.rating) 
         FROM reviews r 
         WHERE r.product_id = p.id),
        0
    ) AS media_avaliacao
FROM products p
ORDER BY media_avaliacao DESC;


-- -----------------------------------------------
-- BLOCO 3 — EXISTS / NOT EXISTS
-- -----------------------------------------------

-- 3.1 Categorias que têm produtos
SELECT 
    c.id,
    c.name AS categoria
FROM categories c
WHERE EXISTS (
    SELECT 1 
    FROM products p 
    WHERE p.category_id = c.id
);

-- 3.2 Categorias SEM produtos (dados inconsistentes)
SELECT 
    c.id,
    c.name AS categoria
FROM categories c
WHERE NOT EXISTS (
    SELECT 1 
    FROM products p 
    WHERE p.category_id = c.id
);


-- ============================================================
-- RESUMO DA AULA:
--   Subquery no WHERE  → Filtra com base em outra consulta
--                       Ex: produtos acima da média
--   
--   Subquery no SELECT → Calcula valores adicionais por linha
--                       Ex: média de avaliações por produto
--   
--   EXISTS / NOT EXISTS → Verifica existência de registros
--                       Ex: categorias com ou sem produtos
--   
--   COALESCE           → Trata NULL em subqueries
--                       Ex: substitui NULL por 0 na média
--   
--   Dica de QA → Use subqueries quando um JOIN simples não resolve
--                Use COALESCE para evitar NULL em relatórios
--                Use NOT EXISTS para encontrar dados faltando
-- ============================================================