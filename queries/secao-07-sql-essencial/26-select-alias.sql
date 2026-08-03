-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 07 - SQL Essencial para QA (na prática)
-- AULA  : 26 - SELECT na Prática
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a extrair dados com SELECT — colunas específicas,
--   alias e exploração das tabelas principais do projeto.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products, categories, suppliers
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — Explorando as tabelas do projeto
-- -----------------------------------------------

-- todas as colunas de products
SELECT * FROM products;

-- todas as colunas de categories
SELECT * FROM categories;

-- todas as colunas de suppliers
SELECT * FROM suppliers;


-- -----------------------------------------------
-- BLOCO 2 — Selecionando colunas específicas
-- -----------------------------------------------

-- só o que interessa de suppliers
SELECT
  id,
  company_name,
  email,
  city
FROM suppliers;


-- -----------------------------------------------
-- BLOCO 3 — Alias: renomeando colunas no resultado
-- -----------------------------------------------

-- alias em português para evidência profissional
SELECT
  name            AS produto,
  price           AS preco,
  stock_quantity  AS estoque,
  is_active       AS ativo
FROM products;


-- ============================================================
-- RESULTADO ESPERADO:
--   SELECT *         → todas as colunas e registros da tabela
--   colunas          → só os campos selecionados
--   alias            → resultado com nomes em português
-- ============================================================