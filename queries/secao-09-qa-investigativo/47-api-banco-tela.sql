-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 47 - Quando a UI Mente: Divergências entre API e Banco
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a investigar divergências entre o que a tela mostra
--   e o que o banco realmente tem. A UI mente — o banco é a verdade.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products, cart_items
-- ============================================================


-- -----------------------------------------------
-- BLOCO 1 — Divergência de Preço
-- -----------------------------------------------

-- PASSO 1: qual é o preço real no banco agora?
UPDATE products
SET price = 199.90   
WHERE name = 'Mouse avenger';

-- PASSO 2: confirma o preço atual
SELECT
    name AS produto,
    price AS preco_atual,
    updated_at AS ultima_atualizacao
FROM products
WHERE name = 'Mouse avenger';


-- -----------------------------------------------
-- BLOCO 2 — Soft Delete: Produto Inativo no Carrinho
-- -----------------------------------------------

-- 2.1 PASSO 1: verifica produto antes de inativar
SELECT
    name AS produto,
    price AS preco_atual,
    updated_at AS ultima_atualizacao,
    is_active AS disponivel
FROM products
WHERE name = 'Produto QA 13';

-- 2.2 PASSO 2: inativa o produto
UPDATE products
SET is_active = false   
WHERE name = 'Produto QA 13';

-- 2.3 PASSO 3: investiga se está no carrinho de alguém
SELECT
    p.name AS produto,
    p.is_active AS produto_ativo,
    ci.user_id AS usuario,
    ci.quantity AS quantidade,
    ci.created_at AS adicionado_ao_carrinho,
    p.updated_at AS produto_atualizado_em
FROM cart_items ci
INNER JOIN products p ON p.id = ci.product_id
WHERE p.is_active = FALSE OR p.name = 'Produto QA 13';

-- 2.4 Mesmo cenário com outro produto
UPDATE products
SET is_active = false   
WHERE name = 'Monitores RGB';

SELECT
    p.name AS produto,
    p.is_active AS produto_ativo,
    ci.user_id AS usuario,
    ci.quantity AS quantidade,
    ci.created_at AS adicionado_ao_carrinho,
    p.updated_at AS produto_atualizado_em
FROM cart_items ci
INNER JOIN products p ON p.id = ci.product_id
WHERE p.is_active = FALSE OR p.name = 'Monitores RGB';


-- -----------------------------------------------
-- BLOCO 3 — Divergência de Contagem: UI vs Banco
-- -----------------------------------------------

-- PASSO 1: quantos produtos ativos o banco tem?
-- ESPERADO: bater com o retorno da API
SELECT COUNT(*) AS total_ativos
FROM products
WHERE is_active = true;

-- PASSO 2: investigando possíveis filtros da API
-- A API pode estar filtrando produtos sem estoque
SELECT COUNT(*) AS produtos_sem_estoque
FROM products
WHERE stock_quantity = 0;


-- ============================================================
-- RESUMO DA AULA:
--   Divergência de Preço  → UI mostra preço antigo, banco tem novo
--   Soft Delete           → Produto inativo ainda no carrinho
--   Divergência de Contagem → UI mostra X, banco tem Y
--   
--   Dica de QA → A UI mente. O banco é a verdade.
--                Use SQL pra provar a divergência.
-- ============================================================