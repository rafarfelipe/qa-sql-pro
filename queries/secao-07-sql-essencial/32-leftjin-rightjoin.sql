-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 07 - SQL Essencial para QA
-- CONTEÚDO: LEFT JOIN e RIGHT JOIN — Encontrando o que Falta
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Usar LEFT JOIN e RIGHT JOIN para encontrar registros que NÃO
--   têm correspondência em outra tabela, identificando dados
--   inconsistentes: categorias sem produtos, produtos sem
--   avaliações ou fornecedores sem produtos cadastrados.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - categories (c), products (p), suppliers (s)
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — LEFT JOIN: Categorias sem Produtos
-- -----------------------------------------------
-- LEFT JOIN retorna TODOS os registros da tabela da ESQUERDA (categories),
-- mesmo que não tenham correspondência na tabela da DIREITA (products).
-- Onde não há correspondência, os campos da direita chegam como NULL.

SELECT
    c.id,
    c."name",
    c.slug,
    c.description,
    c.is_active,
    p.id
FROM
    categories c
LEFT JOIN 
    products p ON p.category_id = c.id
WHERE 
    p.id IS NULL;


-- -----------------------------------------------
-- BLOCO 2 — LEFT JOIN: Categorias com Produtos
-- -----------------------------------------------
-- O oposto do Bloco 1: agora queremos apenas categorias que TÊM produtos.
-- Útil para validar se categorias ativas possuem pelo menos um produto.

SELECT
    c.id,
    c."name",
    c.slug,
    c.description,
    c.is_active,
    p.id
FROM
    categories c
LEFT JOIN 
    products p ON p.category_id = c.id
WHERE 
    p.id IS NOT NULL;


-- -----------------------------------------------
-- BLOCO 3 — RIGHT JOIN: Fornecedores com seus Produtos
-- -----------------------------------------------
-- RIGHT JOIN retorna TODOS os registros da tabela da DIREITA (suppliers),
-- mesmo que não tenham correspondência na tabela da ESQUERDA (products).

SELECT
    f.id AS fornecedor_id,
    f.company_name AS fornecedor,
    p.id AS produto_id,
    p.name AS produto_nome
FROM 
    products p
RIGHT JOIN 
    suppliers f ON f.id = p.supplier_id
WHERE 
    f.company_name <> ''
ORDER BY 
    f.company_name;


-- -----------------------------------------------
-- BLOCO 4 — LEFT JOIN (Equivalente ao RIGHT JOIN acima)
-- -----------------------------------------------
-- Demonstração de que LEFT e RIGHT JOIN são intercambiáveis.
-- Basta inverter a ordem das tabelas e usar LEFT JOIN.

SELECT
    f.id AS fornecedor_id,
    f.company_name AS fornecedor,
    p.id AS produto_id,
    p.name AS produto_nome
FROM 
    suppliers f
LEFT JOIN 
    products p ON f.id = p.supplier_id
WHERE 
    f.company_name <> ''
ORDER BY 
    f.company_name;


-- ============================================================
-- RESULTADO ESPERADO / RESUMO:
--   LEFT JOIN        → Retorna TODOS os registros da tabela da ESQUERDA,
--                      mesmo sem correspondência na DIREITA.
--                      Onde não há match, os campos da direita são NULL.
--   
--   RIGHT JOIN       → Retorna TODOS os registros da tabela da DIREITA,
--                      mesmo sem correspondência na ESQUERDA.
--                      Equivalente a inverter a ordem e usar LEFT JOIN.
--   
--   WHERE ... IS NULL → Filtra apenas os registros que NÃO têm correspondência.
--                        Essa é a combinação clássica para encontrar dados faltantes.
--   
--   WHERE ... IS NOT NULL → Filtra apenas os registros que TÊM correspondência.
--   
--   Dica de QA       → LEFT JOIN + WHERE p.id IS NULL é a dupla dinâmica
--                      para encontrar registros órfãos ou inconsistentes.
--   
--   Casos de Uso     → - Categorias sem produtos--                      
--                      - Fornecedores sem produtos ativos
--                      - Usuários sem pedidos
-- ============================================================