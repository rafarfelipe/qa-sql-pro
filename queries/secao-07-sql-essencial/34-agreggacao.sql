-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 07 - SQL Essencial para QA (na prática)
-- AULA  : 34 - COUNT, MIN, MAX e AVG: resumindo dados para validação
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a usar funções de agregação para resumir e validar dados.
--   Para QAs, essas funções são essenciais para:
--   - Validar a quantidade de registros esperados
--   - Encontrar valores extremos (maior/menor preço)
--   - Calcular médias para análise de consistência
--   - Criar asserts automatizados em testes de dados
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products (p), categories (c), orders (o)
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — COUNT: Contando registros
-- -----------------------------------------------
-- COUNT retorna o número total de registros em uma tabela.
-- Essencial para validar se a quantidade de dados está correta.

-- 1.1 Contando total de produtos
SELECT COUNT(*) AS total_produtos
FROM products;

-- 1.2 Contando total de categorias
SELECT COUNT(*) AS total_categorias
FROM categories;

-- 1.3 Contando produtos ativos
SELECT COUNT(*) AS produtos_ativos
FROM products
WHERE is_active = true;

-- 1.4 Contando produtos inativos
SELECT COUNT(*) AS produtos_inativos
FROM products
WHERE is_active = false;

-- 1.5 Comparando ativos vs inativos (visão consolidada)
SELECT 
    COUNT(*) AS total_produtos,
    SUM(CASE WHEN is_active = true THEN 1 ELSE 0 END) AS ativos,
    SUM(CASE WHEN is_active = false THEN 1 ELSE 0 END) AS inativos
FROM products;


-- -----------------------------------------------
-- BLOCO 2 — MIN, MAX, AVG: Estatísticas básicas
-- -----------------------------------------------
-- MIN = menor valor, MAX = maior valor, AVG = média.
-- Úteis para entender a distribuição dos dados.

-- 2.1 Estatísticas de preço dos produtos ativos
SELECT 
    MIN(price) AS menor_preco,
    MAX(price) AS maior_preco,
    AVG(price) AS preco_medio,
    COUNT(*) AS total
FROM products
WHERE is_active = true;

-- 2.2 Estatísticas de estoque
SELECT 
    MIN(stock_quantity) AS menor_estoque,
    MAX(stock_quantity) AS maior_estoque,
    AVG(stock_quantity) AS estoque_medio,
    COUNT(*) AS total
FROM products
WHERE is_active = true;

-- 2.3 Validando se há produtos com preço zero ou negativo
SELECT 
    COUNT(*) AS produtos_com_preco_zero,
    MIN(price) AS menor_preco
FROM products
WHERE price <= 0;


-- -----------------------------------------------
-- BLOCO 3 — COUNT com DISTINCT
-- -----------------------------------------------
-- Contando valores únicos em uma coluna.

-- 3.1 Quantas categorias diferentes têm produtos?
SELECT 
    COUNT(DISTINCT category_id) AS categorias_com_produtos
FROM products;

-- 3.2 Quantos fornecedores diferentes fornecem produtos ativos?
SELECT 
    COUNT(DISTINCT supplier_id) AS fornecedores_com_produtos_ativos
FROM products
WHERE is_active = true;


-- -----------------------------------------------
-- BLOCO 4 — Combinando com GROUP BY
-- -----------------------------------------------
-- Agrupando dados para análises mais detalhadas.

-- 4.1 Total de produtos por categoria
SELECT 
    c.name AS categoria,
    COUNT(p.id) AS total_produtos,
    AVG(p.price) AS preco_medio
FROM products p
INNER JOIN categories c ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY total_produtos DESC;

-- 4.2 Resumo de pedidos por status
SELECT 
    status,
    COUNT(*) AS total_pedidos,
    MIN(total_amount) AS menor_valor,
    MAX(total_amount) AS maior_valor,
    AVG(total_amount) AS valor_medio
FROM orders
GROUP BY status
ORDER BY status;


-- -----------------------------------------------
-- BLOCO 5 — Exercícios Propostos
-- -----------------------------------------------
-- 1. Quantos produtos têm preço acima da média?
--
-- 2. Qual o valor total de todos os pedidos (SUM)?
--
-- 3. Quantos produtos cada fornecedor tem?
--
-- 4. Qual a média de avaliações (rating) por produto?
--
-- 5. Contar quantos pedidos foram entregues no último mês


-- ============================================================
-- RESUMO DA AULA:
--   COUNT(*)    → Conta o número total de registros
--   COUNT(coluna) → Conta registros com valores não-nulos
--   COUNT(DISTINCT coluna) → Conta valores únicos
--   MIN(coluna) → Retorna o menor valor
--   MAX(coluna) → Retorna o maior valor
--   AVG(coluna) → Retorna a média dos valores
--   SUM(coluna) → Retorna a soma dos valores
--   
--   Dica de QA → Use COUNT para validar quantidade de registros
--                Use MIN/MAX para encontrar outliers (valores extremos)
--                Use AVG para verificar se os dados estão dentro do esperado
--                Combine com CASE WHEN para criar asserts condicionais
--   
--   Casos de Uso → - Validar se todos os produtos têm categoria
--                  - Encontrar produtos com preço acima da média
--                  - Verificar se há pedidos com valor zero
--                  - Contar registros antes e depois de um UPDATE
-- ============================================================