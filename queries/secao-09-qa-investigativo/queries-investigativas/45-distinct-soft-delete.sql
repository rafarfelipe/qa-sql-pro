-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 09 - QA Investigativo
-- CONTEÚDO: DISTINCT e Soft Delete
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Fixar o uso de DISTINCT em investigações de dados.
-- ============================================================


-- ============================================================
-- CT001 — Fornecedores Únicos
-- ============================================================
-- SUSPEITA: Existem produtos cadastrados com fornecedores diferentes.
-- REGRA DE NEGÓCIO: Cada produto deve ter apenas um fornecedor.
-- PERGUNTA: Quantos fornecedores diferentes têm produtos ativos cadastrados?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    COUNT(DISTINCT supplier_id) AS total_fornecedores
FROM products
WHERE is_active = true;

-- EXPLICAÇÃO:
-- COUNT(DISTINCT supplier_id) conta fornecedores únicos
-- WHERE is_active = true filtra apenas produtos ativos


-- ============================================================
-- CT002 — Combinações Únicas de Categoria e Status
-- ============================================================
-- SUSPEITA: Existem combinações de categoria e status inesperadas nos produtos.
-- REGRA DE NEGÓCIO: Produtos devem seguir um padrão consistente de categoria/status.
-- PERGUNTA: Quais são todas as combinações únicas de (categoria, status) existentes?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT DISTINCT
    category_id,
    is_active
FROM products
ORDER BY category_id, is_active;

-- EXPLICAÇÃO:
-- DISTINCT remove duplicatas das combinações
-- ORDER BY organiza para facilitar a análise


-- ============================================================
-- CT003 — Slugs Duplicados
-- ============================================================
-- SUSPEITA: Existem produtos com o mesmo slug, o que violaria unicidade.
-- REGRA DE NEGÓCIO: Cada produto deve ter um slug único.
-- PERGUNTA: Quais slugs estão duplicados e quantas vezes aparecem?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    slug,
    COUNT(*) AS quantidade
FROM products
WHERE slug IS NOT NULL AND slug <> ''
GROUP BY slug
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- EXPLICAÇÃO:
-- GROUP BY slug agrupa produtos pelo slug
-- HAVING COUNT(*) > 1 filtra apenas slugs duplicados
-- WHERE slug IS NOT NULL AND slug <> '' exclui slugs vazios


-- ============================================================
-- RESUMO DAS INVESTIGAÇÕES
-- ============================================================
-- Investigação | Suspeita                              | Condição de Falha
-- ----------|---------------------------------------|--------------------
-- 1         | Fornecedores únicos                   | COUNT(DISTINCT supplier_id)
-- 2         | Combinações categoria/status          | SELECT DISTINCT category_id, is_active
-- 3         | Slugs duplicados                      | GROUP BY slug HAVING COUNT(*) > 1
-- ============================================================
