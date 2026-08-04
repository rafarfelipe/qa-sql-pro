-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- SEÇÃO   : 09 - QA Investigativo
-- BANCO   : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Práticos para fixar o uso de COALESCE e TRIM
--   em investigações de dados.
-- ============================================================


-- ============================================================
-- CT001 — Produtos sem Desconto
-- ============================================================
-- SUSPEITA: Existem produtos cadastrados que não têm desconto definido.
-- REGRA DE NEGÓCIO: Produtos sem desconto devem ter discount_percentage NULL ou 0.
-- PERGUNTA: Quais produtos não têm desconto definido (NULL ou 0)?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    id,
    name,
    price,
    discount_percentage
FROM products
WHERE COALESCE(discount_percentage, 0) = 0
ORDER BY price DESC;

-- EXPLICAÇÃO:
-- COALESCE(discount_percentage, 0) substitui NULL por 0
-- WHERE = 0 filtra produtos sem desconto (NULL ou 0)


-- ============================================================
-- CT002 — Pedidos sem Desconto
-- ============================================================
-- SUSPEITA: Existem pedidos registrados sem desconto aplicado.
-- REGRA DE NEGÓCIO: Pedidos sem desconto devem ter discount_amount NULL ou 0.
-- PERGUNTA: Quais pedidos não têm desconto definido (NULL ou 0)?
-- ============================================================

-- TABELAS ENVOLVIDAS: orders
-- RESPOSTA:

SELECT
    id,
    order_number,
    total_amount,
    discount_amount
FROM orders
WHERE COALESCE(discount_amount, 0) = 0
ORDER BY total_amount DESC;

-- EXPLICAÇÃO:
-- COALESCE(discount_amount, 0) substitui NULL por 0
-- WHERE = 0 filtra pedidos sem desconto (NULL ou 0)


-- ============================================================
-- CT003 — Cálculo de Preço Final com Desconto
-- ============================================================
-- SUSPEITA: Alguns produtos podem ter o cálculo do preço final errado
--           quando o desconto é NULL.
-- REGRA DE NEGÓCIO: O preço final deve considerar desconto NULL como 0.
-- PERGUNTA: Qual o preço final de todos os produtos aplicando o desconto corretamente?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    id,
    name,
    price,
    discount_percentage,
    price - (price * COALESCE(discount_percentage, 0) / 100) AS preco_final
FROM products
ORDER BY preco_final;

-- EXPLICAÇÃO:
-- COALESCE(discount_percentage, 0) garante que NULL seja tratado como 0
-- Fórmula: price - (price * discount_percentage / 100)


-- ============================================================
-- CT004 — Produtos com Espaço no Nome
-- ============================================================
-- SUSPEITA: Existem produtos com espaços desnecessários no início ou fim do nome.
-- REGRA DE NEGÓCIO: Nomes de produtos não devem ter espaços extras.
-- PERGUNTA: Quais produtos têm espaços no início ou fim do nome?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    id,
    name AS nome_original,
    TRIM(name) AS nome_limpo
FROM products
WHERE name != TRIM(name)
ORDER BY id;

-- EXPLICAÇÃO:
-- TRIM(name) remove espaços do início e fim
-- WHERE name != TRIM(name) encontra nomes com espaços extras


-- ============================================================
-- CT005 — Nomes Duplicados por Espaço
-- ============================================================
-- SUSPEITA: Existem produtos que parecem duplicados mas têm espaços diferentes no nome.
-- REGRA DE NEGÓCIO: Não devem existir produtos com nomes duplicados (ignorando espaços).
-- PERGUNTA: Quais nomes de produtos aparecem mais de uma vez (ignorando espaços)?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    TRIM(name) AS nome_limpo,
    COUNT(*) AS quantidade
FROM products
GROUP BY TRIM(name)
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- EXPLICAÇÃO:
-- TRIM(name) normaliza o nome removendo espaços extras
-- GROUP BY + HAVING COUNT(*) > 1 encontra duplicados


-- ============================================================
-- CT006 — Categorias com Espaço no Nome
-- ============================================================
-- SUSPEITA: Existem categorias com espaços desnecessários no início ou fim do nome.
-- REGRA DE NEGÓCIO: Nomes de categorias não devem ter espaços extras.
-- PERGUNTA: Quais categorias têm espaços no início ou fim do nome?
-- ============================================================

-- TABELAS ENVOLVIDAS: categories
-- RESPOSTA:

SELECT
    id,
    name AS nome_original,
    TRIM(name) AS nome_limpo
FROM categories
WHERE name != TRIM(name)
ORDER BY id;

-- EXPLICAÇÃO:
-- TRIM(name) remove espaços do início e fim
-- WHERE name != TRIM(name) encontra nomes com espaços extras


-- ============================================================
-- RESUMO DAS INVESTIGAÇÕES
-- ============================================================
-- Investigação | Suspeita                              | Condição de Falha
-- ----------|---------------------------------------|--------------------
-- 1         | Produtos sem desconto                 | COALESCE(discount_percentage, 0) = 0
-- 2         | Pedidos sem desconto                  | COALESCE(discount_amount, 0) = 0
-- 3         | Cálculo do preço final                | price - (price * COALESCE(discount_percentage, 0) / 100)
-- 4         | Produtos com espaço no nome           | name != TRIM(name)
-- 5         | Nomes duplicados por espaço           | GROUP BY TRIM(name) HAVING COUNT(*) > 1
-- 6         | Categorias com espaço no nome         | name != TRIM(name)
-- ============================================================
