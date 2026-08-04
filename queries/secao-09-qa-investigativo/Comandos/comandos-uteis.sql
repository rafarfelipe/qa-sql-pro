-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- GUIA  : 25 Comandos SQL Mais Utilizados
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Guia de referência rápida com os comandos SQL mais utilizados
--   em investigações de dados. Cada comando com exemplo prático.
-- ============================================================


-- ============================================================
-- 1. TRIM
-- ============================================================
-- Remove espaços do início e fim da string
SELECT 
    id,
    name,
    TRIM(name) AS nome_limpo
FROM products
WHERE name != TRIM(name);


-- ============================================================
-- 2. LENGTH
-- ============================================================
-- Retorna o tamanho (número de caracteres) da string
SELECT 
    id,
    name,
    LENGTH(name) AS tamanho
FROM products
ORDER BY tamanho DESC;


-- ============================================================
-- 3. COALESCE
-- ============================================================
-- Substitui NULL por um valor padrão
SELECT 
    id,
    name,
    price,
    COALESCE(discount_percentage, 0) AS desconto_tratado
FROM products;


-- ============================================================
-- 4. UPPER
-- ============================================================
-- Converte texto para maiúsculo
SELECT 
    id,
    name,
    UPPER(name) AS nome_maiusculo
FROM products;


-- ============================================================
-- 5. LOWER
-- ============================================================
-- Converte texto para minúsculo
SELECT 
    id,
    email,
    LOWER(email) AS email_minusculo
FROM users;


-- ============================================================
-- 6. INITCAP
-- ============================================================
-- Primeira letra de cada palavra em maiúscula
SELECT 
    id,
    name,
    INITCAP(LOWER(name)) AS nome_formatado
FROM products;


-- ============================================================
-- 7. CONCAT
-- ============================================================
-- Concatena strings
SELECT 
    id,
    CONCAT(name, ' - R$ ', price) AS descricao
FROM products;


-- ============================================================
-- 8. SUBSTRING
-- ============================================================
-- Extrai parte de uma string
SELECT 
    id,
    email,
    SUBSTRING(email FROM POSITION('@' IN email) + 1) AS dominio
FROM users;


-- ============================================================
-- 9. REPLACE
-- ============================================================
-- Substitui caracteres em uma string
SELECT 
    id,
    name,
    REPLACE(name, ' ', '_') AS nome_com_underline
FROM products;


-- ============================================================
-- 10. POSITION
-- ============================================================
-- Retorna a posição de um caractere na string
SELECT 
    id,
    email,
    POSITION('@' IN email) AS posicao_arroba
FROM users;


-- ============================================================
-- 11. EXTRACT
-- ============================================================
-- Extrai parte de uma data (ano, mês, dia)
SELECT 
    id,
    created_at,
    EXTRACT(YEAR FROM created_at) AS ano,
    EXTRACT(MONTH FROM created_at) AS mes,
    EXTRACT(DAY FROM created_at) AS dia
FROM orders;


-- ============================================================
-- 12. DATE_PART
-- ============================================================
-- Extrai parte de uma data (alternativa ao EXTRACT)
SELECT 
    id,
    created_at,
    DATE_PART('year', created_at) AS ano,
    DATE_PART('month', created_at) AS mes
FROM orders;


-- ============================================================
-- 13. TO_CHAR
-- ============================================================
-- Formata data para exibição
SELECT 
    id,
    created_at,
    TO_CHAR(created_at, 'DD/MM/YYYY') AS data_brasil,
    TO_CHAR(created_at, 'DD/MM/YYYY HH24:MI') AS data_hora
FROM orders;


-- ============================================================
-- 14. DATE_TRUNC
-- ============================================================
-- Arredonda data para início do período
SELECT 
    id,
    created_at,
    DATE_TRUNC('month', created_at) AS inicio_mes,
    DATE_TRUNC('year', created_at) AS inicio_ano
FROM orders;


-- ============================================================
-- 15. AGE
-- ============================================================
-- Calcula diferença entre duas datas
SELECT 
    id,
    created_at,
    AGE(NOW(), created_at) AS tempo_desde_criacao
FROM orders;


-- ============================================================
-- 16. CURRENT_DATE
-- ============================================================
-- Retorna a data atual
SELECT 
    id,
    created_at,
    CURRENT_DATE - created_at::DATE AS dias_desde_criacao
FROM orders;


-- ============================================================
-- 17. NOW()
-- ============================================================
-- Retorna data e hora atuais
SELECT 
    id,
    created_at,
    NOW() AS data_hora_atual
FROM orders
LIMIT 1;


-- ============================================================
-- 18. INTERVAL
-- ============================================================
-- Soma ou subtrai tempo de uma data
SELECT 
    id,
    created_at,
    created_at + INTERVAL '7 days' AS mais_7_dias,
    created_at - INTERVAL '30 days' AS menos_30_dias
FROM orders;


-- ============================================================
-- 19. STRING_AGG
-- ============================================================
-- Junta valores em uma única string
SELECT 
    category_id,
    STRING_AGG(name, ', ') AS lista_produtos
FROM products
GROUP BY category_id;


-- ============================================================
-- 20. ARRAY_AGG
-- ============================================================
-- Junta valores em um array
SELECT 
    category_id,
    ARRAY_AGG(name) AS lista_produtos
FROM products
GROUP BY category_id;


-- ============================================================
-- 21. NULLIF
-- ============================================================
-- Retorna NULL se dois valores são iguais
SELECT 
    id,
    name,
    discount_percentage,
    NULLIF(discount_percentage, 0) AS desconto_ou_null
FROM products;


-- ============================================================
-- 22. GREATEST
-- ============================================================
-- Retorna o maior valor entre vários
SELECT 
    id,
    price,
    discount_percentage,
    GREATEST(price, COALESCE(discount_percentage, 0)) AS maior_valor
FROM products;


-- ============================================================
-- 23. LEAST
-- ============================================================
-- Retorna o menor valor entre vários
SELECT 
    id,
    price,
    discount_percentage,
    LEAST(price, COALESCE(discount_percentage, 0)) AS menor_valor
FROM products;


-- ============================================================
-- 24. ROUND
-- ============================================================
-- Arredonda um número
SELECT 
    id,
    price,
    ROUND(price, 2) AS preco_arredondado
FROM products;


-- ============================================================
-- 25. CEIL / FLOOR
-- ============================================================
-- Arredonda para cima (CEIL) ou para baixo (FLOOR)
SELECT 
    id,
    price,
    CEIL(price) AS preco_arredondado_cima,
    FLOOR(price) AS preco_arredondado_baixo
FROM products;


-- ============================================================
-- RESUMO RÁPIDO
-- ============================================================
-- Comando          | O que faz
-- -----------------|-------------------------------------------
-- TRIM             | Remove espaços da string
-- LENGTH           | Tamanho da string
-- COALESCE         | Substitui NULL por um valor
-- UPPER/LOWER      | Maiúscula/minúscula
-- INITCAP          | Primeira letra maiúscula
-- CONCAT           | Concatena strings
-- SUBSTRING        | Extrai parte da string
-- REPLACE          | Substitui caracteres
-- POSITION         | Posição do caractere
-- EXTRACT          | Extrai parte da data
-- DATE_PART        | Extrai parte da data (alternativa)
-- TO_CHAR          | Formata data
-- DATE_TRUNC       | Arredonda data
-- AGE              | Diferença entre datas
-- CURRENT_DATE     | Data atual
-- NOW()            | Data e hora atuais
-- INTERVAL         | Soma/subtrai tempo
-- STRING_AGG       | Junta valores em string
-- ARRAY_AGG        | Junta valores em array
-- NULLIF           | Retorna NULL se igual
-- GREATEST         | Maior valor
-- LEAST            | Menor valor
-- ROUND            | Arredonda número
-- CEIL/FLOOR       | Arredonda para cima/baixo
-- ============================================================