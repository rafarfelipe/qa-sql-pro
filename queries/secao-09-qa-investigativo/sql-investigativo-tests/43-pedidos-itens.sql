-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- SEÇÃO   : 09 - QA Investigativo
-- BANCO   : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Cada caso apresenta uma suspeita e você deve montar
--   a query que confirma ou descarta a hipótese.
-- ============================================================

-- ============================================================
-- CT001 — Pedidos sem Itens
-- ============================================================
-- SUSPEITA: Existem pedidos registrados no sistema que não têm nenhum item associado.
-- REGRA DE NEGÓCIO: Todo pedido deve ter pelo menos um item. 
-- PERGUNTA: Quantos pedidos estão sem itens? Quais são eles?
-- ============================================================

-- TABELAS ENVOLVIDAS: orders, order_items
-- RESPOSTA:

SELECT
    o.id AS pedido_id,
    o.order_number,
    o.user_id,
    o.total_amount,
    o.status,
    o.created_at,
    COUNT(oi.id) AS total_itens
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.order_number, o.user_id, o.total_amount, o.status, o.created_at
HAVING COUNT(oi.id) = 0
ORDER BY o.created_at DESC;

-- EXPLICAÇÃO:
-- LEFT JOIN garante que pedidos sem itens apareçam no resultado
-- GROUP BY agrupa por pedido
-- HAVING COUNT(oi.id) = 0 filtra apenas pedidos sem itens


-- ============================================================
-- CT002 — Produtos sem Categoria Válida
-- ============================================================
-- SUSPEITA: Existem produtos cadastrados com uma categoria que
--           não existe mais ou com category_id nulo.
-- REGRA DE NEGÓCIO: Todo produto deve pertencer a uma categoria
--                   válida e ativa.
-- PERGUNTA: Quais produtos não têm uma categoria válida?
-- ============================================================

-- TABELAS ENVOLVIDAS: products, categories
-- RESPOSTA:

SELECT
    p.id,
    p.name AS produto,
    p.category_id,
    p.is_active AS produto_ativo,
    c.id AS categoria_id,
    c.name AS categoria_nome,
    c.is_active AS categoria_ativa
FROM products p
LEFT JOIN categories c ON c.id = p.category_id
WHERE p.category_id IS NULL 
    OR c.id IS NULL
    OR c.is_active = false
ORDER BY p.name;

-- EXPLICAÇÃO:
-- LEFT JOIN garante que produtos sem categoria apareçam
-- WHERE p.category_id IS NULL → produtos sem categoria definida
-- OR c.id IS NULL → category_id não existe na tabela categories
-- OR c.is_active = false → categoria inativa


-- ============================================================
-- CT003 — Usuários sem Pedidos mas com Avaliações
-- ============================================================
-- SUSPEITA: Existem usuários que avaliaram produtos mas nunca
--           fizeram nenhum pedido.
-- REGRA DE NEGÓCIO: Usuário só pode avaliar após comprar.
-- PERGUNTA: Quais usuários têm avaliações mas nunca fizeram
--           nenhum pedido?
-- ============================================================

-- TABELAS ENVOLVIDAS: users, reviews, orders
-- RESPOSTA:

SELECT
    u.id AS usuario_id,
    u.full_name AS usuario,
    u.email,
    COUNT(r.id) AS total_avaliacoes,
    COUNT(o.id) AS total_pedidos
FROM users u
INNER JOIN reviews r ON r.user_id = u.id
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.full_name, u.email
HAVING COUNT(o.id) = 0
    AND COUNT(r.id) > 0
ORDER BY total_avaliacoes DESC;

-- EXPLICAÇÃO:
-- INNER JOIN reviews → apenas usuários que têm avaliações
-- LEFT JOIN orders → para verificar se tem pedidos (mesmo que não tenha)
-- HAVING COUNT(o.id) = 0 → usuários SEM pedidos
-- AND COUNT(r.id) > 0 → usuários COM avaliações


-- ============================================================
-- RESUMO DAS INVESTIGAÇÕES
-- ============================================================
-- Investigação | Suspeita                              | Condição de Falha
-- ----------|---------------------------------------|--------------------
-- 1         | Pedidos sem itens                     | COUNT(oi.id) = 0
-- 2         | Produtos sem categoria válida         | category_id IS NULL OR c.id IS NULL
-- 3         | Usuários com avaliações sem pedidos   | COUNT(o.id) = 0 AND COUNT(r.id) > 0
-- ============================================================