-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 09 - QA Investigativo
-- CONTEÚDO: Divergências Suspeitas
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Investigar divergências entre UI, API e banco. Cada caso
--   apresenta uma suspeita e exige a query que confirma ou
--   descarta a hipótese.
-- ============================================================


-- ============================================================
-- CT001 — Produto Sumiu do Carrinho
-- ============================================================
-- SUSPEITA: Cliente adicionou produto ao carrinho, saiu do site,
--           voltou no dia seguinte e o produto não estava mais lá.
--           Ninguém deletou nada.
-- REGRA DE NEGÓCIO: Produtos inativos devem ser removidos do carrinho automaticamente.
-- PERGUNTA: Existem produtos inativos que ainda estão no carrinho de clientes?
-- ============================================================

-- TABELAS ENVOLVIDAS: cart_items, products
-- RESPOSTA:

SELECT
    p.name AS produto,
    p.is_active AS produto_ativo,
    ci.user_id AS usuario,
    ci.quantity AS quantidade,
    ci.created_at AS adicionado_ao_carrinho,
    p.updated_at AS produto_atualizado_em
FROM cart_items ci
INNER JOIN products p ON p.id = ci.product_id
WHERE p.is_active = false;

-- EXPLICAÇÃO:
-- INNER JOIN conecta carrinho com produtos
-- WHERE p.is_active = false encontra produtos inativos no carrinho
-- Se houver resultados, confirma que o sistema não limpa carrinho de produtos inativos


-- ============================================================
-- CT002 — Pedido com Preço Divergente
-- ============================================================
-- SUSPEITA: Cliente reclamou que no boleto veio R$249,90, mas na tela
--           do produto estava R$199,90.
-- REGRA DE NEGÓCIO: O preço do pedido deve bater com o preço atual do produto.
-- PERGUNTA: Existem pedidos com preço diferente do preço atual do produto?
-- ============================================================

-- TABELAS ENVOLVIDAS: order_items, products
-- RESPOSTA:

SELECT
    oi.id AS item_pedido,
    p.name AS produto,
    oi.price AS preco_no_pedido,
    p.price AS preco_atual_banco,
    oi.created_at AS data_pedido,
    p.updated_at AS produto_atualizado_em,
    CASE
        WHEN oi.price = p.price THEN '✅ Preços iguais'
        ELSE '❌ PREÇO DIVERGE!'
    END AS conclusao
FROM order_items oi
INNER JOIN products p ON p.id = oi.product_id
WHERE oi.price != p.price
ORDER BY oi.created_at DESC;

-- EXPLICAÇÃO:
-- Compara oi.price (preço no momento do pedido) com p.price (preço atual)
-- WHERE oi.price != p.price filtra apenas divergências
-- CASE WHEN adiciona indicador visual da divergência


-- ============================================================
-- CT003 — Contagem de Produtos Não Bate
-- ============================================================
-- SUSPEITA: API retornou 8 produtos ativos, mas o time garante que tem 10.
-- REGRA DE NEGÓCIO: A contagem da API deve bater com o banco de dados.
-- PERGUNTA: Quantos produtos ativos existem no banco vs quantos a API retorna?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

-- Total de produtos ativos no banco
SELECT
    COUNT(*) AS total_ativos_banco
FROM products
WHERE is_active = true;

-- Possíveis filtros aplicados pela API (produtos sem estoque ou sem imagem)
SELECT
    COUNT(*) AS possivel_filtro_api
FROM products
WHERE is_active = true
    AND stock_quantity > 0
    AND image_url IS NOT NULL
    AND price > 0;

-- EXPLICAÇÃO:
-- Primeira query conta todos os ativos no banco
-- Segunda query simula possíveis filtros da API (estoque, imagem, preço)
-- Comparação dos dois valores revela onde está a divergência


-- ============================================================
-- CT004 — Produto Esgotado Ainda Vendendo
-- ============================================================
-- SUSPEITA: Produto 'Mouse Gamer' está com estoque zerado há 3 dias,
--           mas ainda aparece disponível no site.
-- REGRA DE NEGÓCIO: Produtos sem estoque não devem aparecer como disponíveis.
-- PERGUNTA: Existem produtos ativos com estoque zerado?
-- ============================================================

-- TABELAS ENVOLVIDAS: products
-- RESPOSTA:

SELECT
    id,
    name AS produto,
    stock_quantity AS estoque,
    is_active AS ativo,
    updated_at AS ultima_atualizacao
FROM products
WHERE is_active = true
    AND stock_quantity = 0
ORDER BY id;

-- EXPLICAÇÃO:
-- WHERE is_active = true AND stock_quantity = 0
-- Encontra produtos que estão ativos mas não têm estoque
-- Se houver resultados, confirma que a UI ignora o estoque


-- ============================================================
-- CT005 — Status do Pedido Não Atualiza
-- ============================================================
-- SUSPEITA: Cliente recebeu o pedido, mas no site ainda aparece
--           'Em trânsito' há 5 dias.
-- REGRA DE NEGÓCIO: Status deve ser atualizado quando pedido é entregue.
-- PERGUNTA: Existem pedidos com status inconsistente?
-- ============================================================

-- TABELAS ENVOLVIDAS: orders
-- RESPOSTA:

-- Pedidos marcados como entregue mas sem data de entrega
SELECT
    id,
    order_number,
    status,
    delivered_at
FROM orders
WHERE status = 'delivered'
    AND delivered_at IS NULL;

-- EXPLICAÇÃO:
-- WHERE status = 'delivered' AND delivered_at IS NULL
-- Encontra inconsistência entre status e data de entrega
-- Se houver resultados, confirma falha na atualização


-- ============================================================
-- CT006 — Categoria Sumiu da Loja
-- ============================================================
-- SUSPEITA: Categoria 'Eletrônicos' sumiu do menu, mas o time de produto
--           diz que ela está ativa e tem produtos.
-- REGRA DE NEGÓCIO: Categorias ativas com produtos devem aparecer no menu.
-- PERGUNTA: A categoria está ativa? Os produtos estão vinculados corretamente?
-- ============================================================

-- TABELAS ENVOLVIDAS: categories, products
-- RESPOSTA:

SELECT
    c.id AS categoria_id,
    c.name AS categoria,
    c.is_active AS categoria_ativa,
    COUNT(p.id) AS total_produtos,
    SUM(CASE WHEN p.is_active = true THEN 1 ELSE 0 END) AS produtos_ativos
FROM categories c
LEFT JOIN products p ON p.category_id = c.id
WHERE c.name = 'Eletrônicos'
GROUP BY c.id, c.name, c.is_active;

-- EXPLICAÇÃO:
-- LEFT JOIN garante que a categoria aparece mesmo sem produtos
-- COUNT(p.id) conta total de produtos vinculados
-- SUM(CASE...) conta apenas produtos ativos
-- WHERE c.name = 'Eletrônicos' filtra a categoria específica


-- ============================================================
-- RESUMO DAS INVESTIGAÇÕES
-- ============================================================
-- Investigação | Suspeita                              | Condição de Falha
-- ----------|---------------------------------------|--------------------
-- 1         | Produto sumiu do carrinho             | p.is_active = false
-- 2         | Preço do pedido diverge               | oi.price != p.price
-- 3         | Contagem de produtos não bate         | COUNT(*) vs filtros da API
-- 4         | Produto esgotado ainda vendendo       | stock_quantity = 0
-- 5         | Status do pedido não atualiza         | status = 'delivered' AND delivered_at IS NULL
-- 6         | Categoria sumiu da loja               | c.is_active + COUNT(p.id)
-- ============================================================
