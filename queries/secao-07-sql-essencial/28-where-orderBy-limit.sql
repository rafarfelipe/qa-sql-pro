-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 07 - SQL Essencial para QA
-- CONTEÚDO: Filtro, Ordenação e Operadores (WHERE, ORDER BY, LIMIT)
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Extrair dados específicos com filtros (WHERE), operadores de
--   comparação, ordenação (ORDER BY) e controle de volume de
--   registros (LIMIT) — base para validação de dados e testes
--   de API/Banco.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — Limitando resultados (LIMIT)
-- -----------------------------------------------
-- Dica de QA: Use LIMIT para pré-visualizar a estrutura da tabela 
-- sem sobrecarregar a tela ou o servidor com milhares de linhas.

SELECT
    id,
    category_id,
    supplier_id,
    "name",
    slug,
    description,
    short_description,
    price,
    cost_price,
    stock_quantity,
    reorder_level,
    image_url,
    sku,
    barcode,
    weight,
    is_active,
    is_featured,
    discount_percentage,
    rating,
    reviews_count,
    views_count,
    sales_count,
    created_at,
    updated_at
FROM
    public.products
LIMIT 15;


-- -----------------------------------------------
-- BLOCO 2 — Filtrando dados com WHERE (=, <>, >)
-- -----------------------------------------------
-- O WHERE é o coração da validação de dados. Vamos testar os operadores básicos.

-- Igualdade (=): Buscando produtos de uma categoria específica
SELECT
    id,
    category_id,   
    "name",
    price,
    cost_price,      
    is_active  
FROM
    public.products
WHERE 
    category_id = 13    
LIMIT 25;


-- Diferença (<>): Excluindo uma categoria específica
SELECT
    id,
    category_id,   
    "name"  
FROM
    public.products
WHERE 
    category_id <> 13   
ORDER BY 
    category_id  
LIMIT 100;


-- Maior que (>): Buscando categorias acima de um certo ID
SELECT
    id,
    category_id,   
    "name"  
FROM
    public.products
WHERE 
    category_id > 13   
ORDER BY 
    "name" ASC  
LIMIT 200;


-- -----------------------------------------------
-- BLOCO 3 — Ordenando resultados (ORDER BY ASC / DESC)
-- -----------------------------------------------
-- Ordenar é essencial para verificar se a API/Banco está retornando os dados na ordem esperada pela regra de negócio.

-- Descendente (DESC): Do maior para o menor (ou Z-A)
SELECT
    id,
    category_id,   
    "name"  
FROM
    public.products
WHERE 
    category_id <> 13   
ORDER BY 
    category_id DESC  
LIMIT 100;


-- Ascendente (ASC): Do menor para o maior (ou A-Z). 
-- Nota: ASC é o padrão, mas escrevê-lo deixa o código mais legível.
SELECT
    id,
    category_id,   
    "name"  
FROM
    public.products
WHERE 
    category_id <> 13   
ORDER BY 
    "name" ASC  
LIMIT 100;


-- -----------------------------------------------
-- BLOCO 4 — Combinando Filtros e Ordenações Múltiplas
-- -----------------------------------------------
-- Cenário real de QA: Validar regras de negócio complexas (ex: produtos caros de categorias específicas, ordenados por preço).

-- Múltiplas condições com AND + Ordenação simples
SELECT
    id,
    category_id,   
    "name",
    price 
FROM
    products
WHERE 
    category_id > 13
    AND price > 1234
ORDER BY 
    price 
LIMIT 25;


-- Múltiplas condições com AND + Ordenação em cascata (Hierarquia)
-- Primeiro ordena por categoria (DESC), e se houver empate, ordena por preço (ASC)
SELECT
    id,
    category_id,   
    "name",
    price 
FROM
    products
WHERE 
    category_id > 13
    AND price > 1234
ORDER BY 
    category_id DESC,
    price ASC 
LIMIT 25;


-- ============================================================
-- RESULTADO ESPERADO / RESUMO:
--   LIMIT          → Controla a quantidade de linhas retornadas (ex: 15, 25, 100).
--   WHERE (=, <>)  → Filtra dados exatos ou exclui valores indesejados.
--   WHERE (>)      → Filtra dados baseados em limites mínimos/numéricos.
--   ORDER BY       → Organiza o resultado (ASC para crescente/A-Z, DESC para decrescente/Z-A).
--   AND            → Refina o filtro exigindo que múltiplas condições sejam verdadeiras.
--   ORDER BY (x,y) → Cria uma ordenação em cascata (hierarquia de desempate).
-- ============================================================