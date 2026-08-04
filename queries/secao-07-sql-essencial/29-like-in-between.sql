-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 07 - SQL Essencial para QA
-- CONTEÚDO: Buscas Inteligentes para Testes (LIKE, IN, BETWEEN)
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Refinar a extração de dados com operadores de padrão (LIKE),
--   listas de valores (IN/NOT IN) e intervalos (BETWEEN) para
--   validar regras de busca, faixas de preço e cenários de borda
--   (boundary testing).
-- ============================================================
-- TABELAS UTILIZADAS:
--   - categories, products
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — Explorando a tabela de Categorias
-- -----------------------------------------------
-- Pré-visualizando a estrutura e os dados disponíveis.

SELECT
    id,
    "name",
    slug,
    description,
    image_url,
    icon,
    display_order,
    is_active,
    created_at
FROM
    public.categories
LIMIT 15;


-- -----------------------------------------------
-- BLOCO 2 — O Poder do LIKE: Busca por Padrões
-- -----------------------------------------------
-- Dica de QA: O LIKE é fundamental para validar se a "barra de busca" 
-- da aplicação está retornando os resultados corretos conforme o usuário digita.

-- Começa com: O curinga (%) no final busca qualquer texto que INICIE com "Produtos"
SELECT
    id,
    "name",
    slug,
    description,      
    created_at
FROM
    categories
WHERE 
    description LIKE 'Produtos%'
LIMIT 15;


-- Contém: O curinga (%) em ambos os lados busca qualquer texto que CONTENHA "variados"
SELECT
    id,
    "name",
    slug,
    description,      
    created_at
FROM
    categories
WHERE 
    description LIKE '%variados%'
LIMIT 15;


-- Termina com: O curinga (%) apenas no início busca textos que TERMINEM com "variados"
SELECT
    id,
    "name",
    slug,
    description,      
    created_at
FROM
    categories
WHERE 
    description LIKE '%variados'
LIMIT 105;


-- -----------------------------------------------
-- BLOCO 3 — O Operador IN: Filtrando Listas de Valores
-- -----------------------------------------------
-- Dica de QA: Use IN para validar se um lote específico de IDs ou nomes 
-- foi processado corretamente, evitando múltiplas cláusulas "OR".

-- Filtrando por uma lista de IDs numéricos
SELECT
    id,
    "name",
    slug,
    description,      
    created_at
FROM
    categories
WHERE 
    id IN (9, 19, 61, 84)
LIMIT 105;


-- Dica de Ouro (Debug): Comentar o WHERE com "--" é a forma mais rápida 
-- de desativar um filtro temporariamente para validar o SELECT sem reescrever o código.
SELECT
    id,
    "name",
    slug,
    description,      
    created_at
FROM
    categories
    -- WHERE id IN (9, 19, 61, 84)
LIMIT 105;


-- Filtrando por uma lista de textos (Strings exigem aspas simples)
SELECT
    id,
    "name",
    slug,
    description,      
    created_at
FROM
    categories
WHERE 
    "name" IN ('Roupas', 'Pets')
LIMIT 105;


-- Negando a lista: Trazendo tudo, EXCETO o que está na lista (NOT IN)
SELECT
    id,
    "name",
    slug,
    description,      
    created_at
FROM
    categories
WHERE 
    "name" NOT IN ('Roupas', 'Pets')
LIMIT 105;


-- -----------------------------------------------
-- BLOCO 4 — Explorando a tabela de Produtos
-- -----------------------------------------------
-- Pré-visualizando a estrutura para os próximos filtros de intervalo.

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
LIMIT 10;


-- -----------------------------------------------
-- BLOCO 5 — O Operador BETWEEN: Filtros de Intervalo (Ranges)
-- -----------------------------------------------
-- Dica de QA: O BETWEEN é inclusivo (inclui o valor inicial e final). 
-- É perfeito para Testes de Fronteira (Boundary Testing) e validação de faixas.

-- Faixa de Preço: Buscando produtos entre R$ 1000 e R$ 1300
SELECT
    id,  
    "name",
    slug,
    description,  
    price,  
    stock_quantity,  
    sku,    
    updated_at
FROM
    products
WHERE 
    price BETWEEN 1000 AND 1300
LIMIT 10;


-- Faixa de IDs: Útil para isolar um lote específico de registros para auditoria
SELECT
    id,  
    "name",
    slug,
    description,  
    price,  
    stock_quantity,  
    sku,    
    updated_at
FROM
    products
WHERE 
    id BETWEEN 499 AND 550
LIMIT 10;


-- Cenário de Anomalia (Edge Case): Buscando estoques negativos ou zerados.
-- Em QA, é crucial encontrar dados inconsistentes que possam quebrar o front-end.
SELECT
    id,  
    "name",
    slug,
    description,  
    price,  
    stock_quantity,  
    sku,    
    updated_at
FROM
    products
WHERE 
    stock_quantity BETWEEN -10 AND 0
LIMIT 10;


-- ============================================================
-- RESULTADO ESPERADO / RESUMO:
--   LIKE '%texto'  → Busca fuzzy (padrões). % no início = termina com; 
--                     % no fim = começa com; % em ambos = contém.
--   IN (a, b, c)   → Filtra registros que correspondem a qualquer valor da lista.
--   NOT IN (a, b)  → Exclui registros que correspondem aos valores da lista.
--   BETWEEN x AND y→ Filtra registros dentro de um intervalo (inclusivo).
--   Dica de QA     → Comentar o WHERE (--) acelera o debug durante a escrita dos testes.
-- ============================================================