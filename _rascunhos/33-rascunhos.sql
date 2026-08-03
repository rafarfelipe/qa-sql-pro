-- extraindo partes da data
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
	EXTRACT(YEAR FROM o.created_at) = 2026		
LIMIT 30;

-- 

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
	EXTRACT(YEAR FROM o.created_at) = 2026
	AND o.created_at BETWEEN '2026-04-18' AND '2026-07-04'	
LIMIT 30;





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
	EXTRACT(YEAR FROM o.created_at) = 2026
	AND o.created_at BETWEEN '2026-04-18' AND '2026-07-04'
	AND o.created_at > '2026-07-03'
LIMIT 30;




-- padronizando maiúscula/minúscula
SELECT
    u.id,
    u.full_name,
    UPPER(u.full_name) AS nome_maiusculo,
    LOWER(u.full_name) AS nome_minusculo
FROM
    users u
LIMIT 10;




-- removendo espaços extras
SELECT
    u.id,
    u.full_name,
    TRIM(u.full_name) AS nome_sem_espacos
FROM
    users u
LIMIT 10;






-- classificando pedidos por valor
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








