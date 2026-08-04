-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 44 - COALESCE e TRIM: tratando dados nulos e vazios na investigação
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a usar COALESCE e TRIM para limpar dados sujos
--   antes de investigar. Dados com NULL ou espaços podem esconder
--   bugs ou gerar falsos positivos.
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — COALESCE: Substituindo NULL
-- -----------------------------------------------

-- ❌ SEM COALESCE: quebra quando discount_percentage é NULL
SELECT
    id,
    name,
    price,
    discount_percentage,
    price - (price * discount_percentage / 100) AS preco_com_desconto
FROM products
LIMIT 35;

-- ✅ COM COALESCE: funciona sempre
SELECT
    id,
    name,
    price,
    discount_percentage,
    price - (price * COALESCE(discount_percentage, 0) / 100) AS preco_com_desconto
FROM products
LIMIT 35;


-- -----------------------------------------------
-- BLOCO 2 — Investigação com COALESCE
-- -----------------------------------------------

-- ❌ ERRADO: produtos com NULL não aparecem
SELECT
    id,
    name,
    price,
    discount_percentage
FROM products
WHERE discount_percentage = 0;

-- ✅ CORRETO: COALESCE inclui os NULL
SELECT
    id,
    name,
    price,
    discount_percentage,
    COALESCE(discount_percentage, 0) AS desconto_tratado
FROM products
WHERE COALESCE(discount_percentage, 0) = 0
ORDER BY price DESC;


-- -----------------------------------------------
-- BLOCO 3 — TRIM: Removendo Espaços
-- -----------------------------------------------

-- O problema:
-- 'Camiseta'    → SEM espaço
-- 'Camiseta '   → COM espaço no final
-- ' Camiseta'   → COM espaço no começo
-- ' Camiseta '  → COM espaço dos dois lados
--
-- Pra você, é a mesma palavra. Pro banco, são QUATRO palavras diferentes!


-- -----------------------------------------------
-- BLOCO 4 — Plantando Dados com Espaços
-- -----------------------------------------------

INSERT INTO products
(category_id, supplier_id, name, slug, description, price, stock_quantity, sku, is_active, reviews_count, created_at)
VALUES
(5, 8, 'Camiseta Premium ', 'camiseta-premium', 'Camiseta com espaço no final', 49.90, 10, 'SKU-CAMISETA-01', TRUE, 0, now()),
(6, 8, ' Tênis Esportivo', 'tenis-esportivo', 'Tênis com espaço no começo', 89.90, 15, 'SKU-TENIS-02', TRUE, 0, now()),
(10, 9, ' Calça Jeans ', 'calca-jeans', 'Calça com espaço dos dois lados', 79.90, 20, 'SKU-CALCA-03', TRUE, 0, now()),
(11, 10, 'Camiseta Premium ', 'camiseta-premium-2', 'Duplicado com espaço no final', 49.90, 8, 'SKU-CAMISETA-04', TRUE, 0, now()),
(12, 11, ' Jaqueta  Couro', 'jaqueta-couro', 'Jaqueta com espaço duplo', 199.90, 5, 'SKU-JAQUETA-05', TRUE, 0, now()),
(12, 11, 'Notebook Gamer ', 'notebook-gamer', 'Notebook com espaço no final', 3500.00, 10, 'SKU-NOTE-01', TRUE, 0, now()),
(12, 11, ' Mouse RGB', 'mouse-rgb', 'Mouse com espaço no começo', 150.00, 25, 'SKU-MOUSE-02', TRUE, 0, now()),
(12, 11, ' Teclado Mecânico ', 'teclado-mecanico', 'Teclado com espaço dos dois lados', 280.00, 15, 'SKU-TECLA-03', TRUE, 0, now()),
(12, 11, 'Monitor 24" ', 'monitor-24', 'Monitor com espaço no final', 1200.00, 8, 'SKU-MONITOR-04', TRUE, 0, now()),
(12, 11, ' Headset Gamer', 'headset-gamer', 'Headset com espaço no começo', 320.00, 20, 'SKU-HEADSET-05', TRUE, 0, now()),
(12, 11, ' Cadeira Gamer ', 'cadeira-gamer', 'Cadeira com espaço dos dois lados', 800.00, 5, 'SKU-CADEIRA-06', TRUE, 0, now()),
(12, 11, 'SSD 1TB ', 'ssd-1tb', 'SSD com espaço no final', 450.00, 30, 'SKU-SSD-07', TRUE, 0, now()),
(12, 11, ' Memória RAM', 'memoria-ram', 'Memória com espaço no começo', 350.00, 18, 'SKU-RAM-08', TRUE, 0, now()),
(12, 11, ' Placa de Vídeo ', 'placa-video', 'Placa de vídeo com espaço dos dois lados', 2000.00, 6, 'SKU-VIDEO-09', TRUE, 0, now()),
(12, 11, 'Fonte 650W ', 'fonte-650w', 'Fonte com espaço no final', 280.00, 12, 'SKU-FONTE-10', TRUE, 0, now());


-- -----------------------------------------------
-- BLOCO 5 — Investigação com TRIM
-- -----------------------------------------------

-- 1. SEM TRIM: mostrando os nomes com espaço
SELECT
    id,
    name
FROM products
WHERE name LIKE ' %'      -- espaço no começo
   OR name LIKE '% '      -- espaço no final
   OR name LIKE '%  %';   -- espaço duplo no meio

-- 2. COM TRIM: comparando nome original com nome limpo
SELECT
    id,
    name AS nome_original,
    TRIM(name) AS nome_limpo
FROM products
WHERE name != TRIM(name);

-- 3. Verificando os produtos com espaços (detalhado)
SELECT
    id,
    name,
    LENGTH(name) AS tamanho,
    TRIM(name) AS nome_limpo,
    LENGTH(TRIM(name)) AS tamanho_limpo,
    CASE 
        WHEN name != TRIM(name) THEN '⚠️ TEM ESPAÇO'
        ELSE '✅ LIMPO'
    END AS situacao
FROM products
WHERE name LIKE '% %' 
   OR name LIKE '% ' 
   OR name LIKE ' %'
ORDER BY id DESC
LIMIT 30;

-- 4. AGRUPADO: contando produtos com mesmo nome (ignorando espaços)
SELECT
    TRIM(name) AS nome_limpo,
    COUNT(*) AS quantidade
FROM products
WHERE name != TRIM(name)
GROUP BY TRIM(name)
ORDER BY quantidade DESC;


-- ============================================================
-- RESUMO DA AULA:
--   COALESCE → Substitui NULL por um valor padrão
--              Ex: COALESCE(discount_percentage, 0)
--   
--   TRIM     → Remove espaços do início e fim da string
--              Ex: TRIM(name)
--   
--   Dica de QA → Use COALESCE para não perder dados em comparações
--                Use TRIM para revelar duplicidades escondidas
-- ============================================================