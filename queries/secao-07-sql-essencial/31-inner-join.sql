-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 07 - SQL Essencial para QA
-- CONTEÚDO: INNER JOIN — Relacionando Tabelas
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Cruzar dados de múltiplas tabelas com INNER JOIN para validar a
--   integridade referencial do banco (ex: garantir que não existem
--   produtos "órfãos" sem categoria ou fornecedor) e montar
--   relatórios completos.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products (p), categories (c), suppliers (s)
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — O Primeiro JOIN: Products + Categories
-- -----------------------------------------------
-- Conectando a tabela de produtos à sua respectiva categoria.
-- Nota: Usamos "apelidos" (aliases) para as tabelas (p, c) para deixar o código mais limpo.

SELECT
    p.id,
    p.category_id,
    c."name",
    p.supplier_id,	
    p."name",
    p.slug,
    p.description
FROM
    products p
INNER JOIN 
    categories c ON c.id = p.category_id;


-- -----------------------------------------------
-- BLOCO 2 — Múltiplos JOINs: A "Família" Completa
-- -----------------------------------------------
-- Agora cruzamos três tabelas: Produto, Categoria e Fornecedor.
-- O INNER JOIN só retorna registros que têm correspondência em TODAS as tabelas.

SELECT
    p.id,
    p.category_id,
    c."name",
    p.supplier_id,
    s.company_name,
    p."name",
    p.slug,
    p.description
FROM
    products p
INNER JOIN 
    categories c ON c.id = p.category_id
INNER JOIN 
    suppliers s ON s.id = p.supplier_id;


-- -----------------------------------------------
-- BLOCO 3 — Limpando o Resultado (Aliases e Comentários)
-- -----------------------------------------------
-- Dica de QA: Ao gerar evidências ou relatórios, oculte os IDs (chaves estrangeiras) 
-- e use aliases em português para deixar o resultado amigável para a equipe.
-- (As colunas p.category_id e p.supplier_id foram "comentadas" para não poluir a tela).

SELECT
    p.id,
    -- p.category_id,
    c."name" AS categoria,
    -- p.supplier_id,
    s.company_name AS fornecedor,
    p."name",
    p.slug
FROM
    products p
INNER JOIN 
    categories c ON c.id = p.category_id
INNER JOIN 
    suppliers s ON s.id = p.supplier_id;


-- -----------------------------------------------
-- BLOCO 4 — Combinando JOINs com Filtros (WHERE)
-- -----------------------------------------------
-- O poder real do JOIN: cruzar tabelas E filtrar o resultado com base nas regras de negócio.

-- Igualdade (=): Exibindo apenas os produtos da categoria 'Livros'
SELECT
    p.id,
    -- p.category_id,
    c."name" AS categoria,
    -- p.supplier_id,
    s.company_name AS fornecedor,
    p."name",
    p.slug
FROM
    products p
INNER JOIN 
    categories c ON c.id = p.category_id
INNER JOIN 
    suppliers s ON s.id = p.supplier_id  
WHERE 
    c."name" = 'Livros';


-- Diferença (<>): Exibindo todos os produtos, EXCETO os da categoria 'Livros'
SELECT
    p.id,
    -- p.category_id,
    c."name" AS categoria,
    -- p.supplier_id,
    s.company_name AS fornecedor,
    p."name",
    p.slug
FROM
    products p
INNER JOIN 
    categories c ON c.id = p.category_id
INNER JOIN 
    suppliers s ON s.id = p.supplier_id  
WHERE 
    c."name" <> 'Livros';


-- ============================================================
-- RESULTADO ESPERADO / RESUMO:
--   INNER JOIN       → Retorna apenas os registros que têm correspondência 
--                       exata em ambas as tabelas (interseção).
--   Aliases de Tabela(p, c, s) → Atalhos para não repetir o nome da tabela toda hora.
--   Aliases de Coluna(AS)      → Renomeia a saída para um formato mais legível (ex: categoria).
--   Múltiplos JOINs  → Podem ser encadeados infinitamente para cruzar várias tabelas.
--   Dica de QA       → Use comentários (--) para ocultar colunas de IDs (chaves) 
--                       ao gerar relatórios ou evidências de testes.
-- ============================================================