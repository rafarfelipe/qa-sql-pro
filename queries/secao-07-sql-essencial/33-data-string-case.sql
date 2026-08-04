-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 07 - SQL Essencial para QA
-- CONTEÚDO: Funções de Data, String e CASE WHEN
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Manipular dados com funções de data, string e CASE WHEN para
--   validar formatos, padronizar dados e criar classificações
--   personalizadas que tornam os relatórios mais legíveis.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - orders (o), users (u)
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — Funções de Data
-- -----------------------------------------------
-- Extraindo partes de uma data e calculando diferenças.

-- 1.1 Extraindo ano, mês e dia do pedido
SELECT
    o.id,
    o.order_number,
    o.created_at,
    EXTRACT(YEAR FROM o.created_at) AS ano,
    EXTRACT(MONTH FROM o.created_at) AS mes,
    EXTRACT(DAY FROM o.created_at) AS dia
FROM
    orders o
LIMIT 10;

-- 1.2 Filtrando pedidos apenas do ano de 2025
SELECT
    o.id,
    o.order_number,
    o.created_at,
    EXTRACT(YEAR FROM o.created_at) AS ano,
    EXTRACT(MONTH FROM o.created_at) AS mes,
    EXTRACT(DAY FROM o.created_at) AS dia
FROM
    orders o
WHERE 
    EXTRACT(YEAR FROM o.created_at) = 2025
LIMIT 10;

-- 1.3 Calculando idade do pedido em dias
SELECT
    o.id,
    o.order_number,
    o.created_at,
    CURRENT_DATE - o.created_at::DATE AS dias_desde_criacao
FROM
    orders o
LIMIT 10;

-- 1.4 Formatando data para o padrão Brasil (DD/MM/YYYY)
SELECT
    o.id,
    o.order_number,
    o.created_at,
    TO_CHAR(o.created_at, 'DD/MM/YYYY') AS data_brasil,
    TO_CHAR(o.created_at, 'DD/MM/YYYY HH24:MI') AS data_hora_brasil
FROM
    orders o
LIMIT 10;


-- -----------------------------------------------
-- BLOCO 2 — Funções de String
-- -----------------------------------------------
-- Manipulando e padronizando dados textuais.

-- 2.1 Convertendo nomes para maiúscula e minúscula
SELECT
    u.id,
    u.full_name,
    UPPER(u.full_name) AS nome_maiusculo,
    LOWER(u.full_name) AS nome_minusculo
FROM
    users u
LIMIT 10;

-- 2.2 Extraindo domínio do email
SELECT
    u.id,
    u.email,
    SUBSTRING(u.email FROM POSITION('@' IN u.email) + 1) AS dominio
FROM
    users u
LIMIT 10;

-- 2.3 Removendo espaços extras do nome
SELECT
    u.id,
    u.full_name,
    TRIM(u.full_name) AS nome_sem_espacos
FROM
    users u
LIMIT 10;


-- -----------------------------------------------
-- BLOCO 3 — CASE WHEN
-- -----------------------------------------------
-- Criando lógica condicional para classificar dados.

-- 3.1 Classificando pedidos por valor (Baixo, Médio, Alto)
SELECT
    o.id,
    o.order_number,
    o.total_amount,
    CASE 
        WHEN o.total_amount < 100 THEN 'Baixo'
        WHEN o.total_amount >= 100 AND o.total_amount < 500 THEN 'Médio'
        WHEN o.total_amount >= 500 THEN 'Alto'
    END AS categoria_valor
FROM
    orders o
LIMIT 20;

-- 3.2 Classificando status do pedido de forma amigável
SELECT
    o.id,
    o.order_number,
    o.status,
    CASE 
        WHEN o.status = 'pending' THEN 'Aguardando pagamento'
        WHEN o.status = 'processing' THEN 'Em processamento'
        WHEN o.status = 'shipped' THEN 'Enviado'
        WHEN o.status = 'delivered' THEN 'Entregue'
        WHEN o.status = 'cancelled' THEN 'Cancelado'
    END AS status_descricao
FROM
    orders o
LIMIT 20;


-- -----------------------------------------------
-- BLOCO 4 — Combinando Funções
-- -----------------------------------------------
-- Usando múltiplas funções em uma única consulta.

-- 4.1 Relatório completo de pedidos (Data, String e CASE)
SELECT
    o.id AS pedido_id,
    o.order_number,
    TO_CHAR(o.created_at, 'DD/MM/YYYY') AS data_pedido,
    UPPER(u.full_name) AS cliente,
    o.total_amount,
    CASE 
        WHEN o.total_amount < 100 THEN 'Baixo'
        WHEN o.total_amount >= 100 AND o.total_amount < 500 THEN 'Médio'
        WHEN o.total_amount >= 500 THEN 'Alto'
    END AS categoria_valor,
    CASE 
        WHEN o.status = 'delivered' THEN '✅ Entregue'
        WHEN o.status = 'cancelled' THEN '❌ Cancelado'
        ELSE '⏳ Pendente'
    END AS situacao
FROM
    orders o
INNER JOIN 
    users u ON u.id = o.user_id
WHERE 
    o.created_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY 
    o.created_at DESC
LIMIT 20;

-- 4.2 Validando pedidos com possíveis inconsistências
SELECT
    o.id,
    o.order_number,
    o.created_at,
    o.delivered_at,
    CASE 
        WHEN o.delivered_at IS NOT NULL AND o.delivered_at < o.created_at THEN '⚠️ Data de entrega anterior à criação'
        WHEN o.delivered_at IS NULL AND o.status = 'delivered' THEN '⚠️ Status entregue sem data'
        WHEN o.delivered_at IS NOT NULL AND o.status != 'delivered' THEN '⚠️ Data de entrega sem status'
        ELSE '✅ Consistente'
    END AS inconsistencia
FROM
    orders o
WHERE 
    o.delivered_at IS NOT NULL 
    OR o.status = 'delivered'
LIMIT 20;


-- ============================================================
-- RESUMO:
--   Funções de Data   → EXTRACT (extrair partes), TO_CHAR (formatar)
--   Funções de String → UPPER/LOWER (maiúscula/minúscula), 
--                        SUBSTRING (extrair parte), TRIM (remover espaços)
--   CASE WHEN         → Lógica condicional (SE/ENTÃO/SENÃO)
--   
--   Dica de QA       → Use TO_CHAR para padronizar datas em relatórios
--                      Use UPPER/LOWER para padronizar textos antes de comparar
--                      Use CASE WHEN para criar classificações legíveis
--                      Use CURRENT_DATE para validações com data atual
--   
--   Casos de Uso     → - Validar que pedidos não têm data futura
--                      - Padronizar emails antes de verificar duplicidade
--                      - Classificar pedidos por faixa de valor
--                      - Gerar relatórios com status em português
-- ============================================================