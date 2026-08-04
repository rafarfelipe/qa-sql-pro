-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- SEÇÃO   : 09 - QA Investigativo
-- BANCO   : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Práticos para fixar os conceitos de DISTINCT,
--   Soft Delete, UUID e CAST em investigações de dados.
-- ============================================================


-- ============================================================
-- CT001 — Fornecedores Únicos de Produtos Ativos
-- ============================================================
-- SUSPEITA: Existem fornecedores diferentes para produtos ativos.
-- REGRA DE NEGÓCIO: Cada produto deve ter apenas um fornecedor.
-- PERGUNTA: Quantos fornecedores diferentes têm produtos ativos?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    COUNT(DISTINCT supplier_id) AS total_fornecedores
FROM products
WHERE is_active = true;

-- EXPLICAÇÃO:
-- COUNT(DISTINCT supplier_id) conta fornecedores únicos
-- WHERE is_active = true considera apenas produtos ativos


-- ============================================================
-- CT002 — Produtos Inativos no Carrinho (Soft Delete)
-- ============================================================
-- SUSPEITA: Existem produtos inativos que ainda estão no carrinho de clientes.
-- REGRA DE NEGÓCIO: Produtos inativos não devem aparecer no carrinho.
-- PERGUNTA: Quais produtos inativos estão no carrinho de clientes?
-- ============================================================

-- TABELAS ENVOLVIDAS: cart_items, products
-- RESPOSTA:

SELECT
    ci.id AS item_carrinho,
    ci.user_id,
    p.name AS produto,
    p.is_active AS ativo
FROM cart_items ci
INNER JOIN products p ON p.id = ci.product_id
WHERE p.is_active = false;

-- EXPLICAÇÃO:
-- INNER JOIN conecta carrinho com produtos
-- WHERE p.is_active = false encontra produtos inativos no carrinho
-- Soft delete mantém o produto no banco, mas is_active = false


-- ============================================================
-- CT003 — UUIDs Inválidos
-- ============================================================
-- SUSPEITA: Existem usuários com UUID em formato inválido.
-- REGRA DE NEGÓCIO: Todos os UUIDs devem ter exatamente 36 caracteres.
-- PERGUNTA: Quais usuários têm UUID com tamanho diferente de 36?
-- ============================================================

-- TABELAS ENVOLVIDAS: users
-- RESPOSTA:

SELECT
    id,
    LENGTH(id::TEXT) AS tamanho
FROM users
WHERE LENGTH(id::TEXT) != 36;

-- EXPLICAÇÃO:
-- id::TEXT converte UUID para texto
-- LENGTH() conta caracteres
-- WHERE != 36 encontra UUIDs inválidos


-- ============================================================
-- CT004 — Tamanho da Data como Texto
-- ============================================================
-- SUSPEITA: Datas podem ter tamanhos inconsistentes no formato texto.
-- REGRA DE NEGÓCIO: Todas as datas devem ter o mesmo formato e tamanho.
-- PERGUNTA: Qual o tamanho da string da data de criação dos pedidos?
-- ============================================================

-- TABELAS ENVOLVIDAS: orders
-- RESPOSTA:

SELECT
    id,
    created_at,
    LENGTH(created_at::TEXT) AS tamanho_data
FROM orders
LIMIT 10;

-- EXPLICAÇÃO:
-- created_at::TEXT converte timestamp para texto
-- LENGTH() mostra o tamanho da string
-- LIMIT 10 é apenas amostra para verificação


-- ============================================================
-- CT005 — Preço Convertido para Inteiro
-- ============================================================
-- SUSPEITA: A conversão de preço para inteiro pode causar perda de precisão.
-- REGRA DE NEGÓCIO: Preços devem ser tratados corretamente em cálculos.
-- PERGUNTA: Como fica o preço dos produtos quando convertido para inteiro?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    id,
    name,
    price,
    price::TEXT AS preco_texto,
    price::INTEGER AS preco_inteiro
FROM products
LIMIT 10;

-- EXPLICAÇÃO:
-- price::TEXT converte para string
-- price::INTEGER converte para inteiro (trunca decimais)
-- LIMIT 10 é amostra para verificação


-- ============================================================
-- CT006 — ID do Produto como Texto
-- ============================================================
-- SUSPEITA: IDs podem ter tamanhos inconsistentes quando convertidos.
-- REGRA DE NEGÓCIO: Todos os IDs de produtos devem ter o mesmo tamanho.
-- PERGUNTA: Qual o tamanho do ID do produto quando convertido para texto?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    id,
    id::TEXT AS id_texto,
    LENGTH(id::TEXT) AS tamanho_id
FROM products
LIMIT 10;

-- EXPLICAÇÃO:
-- id::TEXT converte para string
-- LENGTH() mostra o tamanho
-- LIMIT 10 é amostra para verificação


-- ============================================================
-- RESUMO DOS EXERCÍCIOS
-- ============================================================
-- Exercício | Suspeita                              | Condição de Falha
-- ----------|---------------------------------------|--------------------
-- 1         | Fornecedores únicos                   | COUNT(DISTINCT supplier_id)
-- 2         | Produtos inativos no carrinho         | p.is_active = false
-- 3         | UUIDs inválidos                       | LENGTH(id::TEXT) != 36
-- 4         | Tamanho da data como texto            | LENGTH(created_at::TEXT)
-- 5         | Preço convertido para inteiro         | price::INTEGER
-- 6         | ID do produto como texto              | LENGTH(id::TEXT)
-- ============================================================
