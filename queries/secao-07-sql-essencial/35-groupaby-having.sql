-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 07 - SQL Essencial para QA (na prática)
-- AULA  : 35 - GROUP BY e HAVING: agrupando e filtrando resultados
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a agrupar dados com GROUP BY e filtrar grupos com HAVING.
--   Para QAs, isso é essencial para:
--   - Validar a distribuição de dados por categorias
--   - Encontrar grupos com valores inconsistentes
--   - Gerar relatórios consolidados para a equipe
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products (p), suppliers (s), categories (c)
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — GROUP BY: Agrupando dados
-- -----------------------------------------------

-- 1.1 Total de produtos por fornecedor
SELECT 
    s.company_name AS fornecedor,
    COUNT(p.id) AS total_produtos
FROM products p
INNER JOIN suppliers s ON s.id = p.supplier_id
GROUP BY s.id, s.company_name
ORDER BY total_produtos DESC;

-- 1.2 Estatísticas de produtos ativos
SELECT 
    COUNT(p.id) AS total_produtos,
    AVG(p.price) AS preco_medio
FROM products p
INNER JOIN categories c ON c.id = p.category_id
WHERE p.is_active = true;


-- -----------------------------------------------
-- BLOCO 2 — HAVING: Filtrando grupos
-- -----------------------------------------------

-- 2.1 Categorias com pelo menos 3 produtos e preço médio acima de R$100
SELECT 
    c.name AS categoria,
    COUNT(p.id) AS total_produtos,
    AVG(p.price) AS preco_medio
FROM products p
INNER JOIN categories c ON c.id = p.category_id
WHERE p.is_active = true
GROUP BY c.id, c.name
HAVING COUNT(p.id) >= 3
   AND AVG(p.price) > 100
ORDER BY preco_medio DESC;

-- 2.2 Categorias com pelo menos 6 produtos
SELECT 
    c.name AS categoria,
    COUNT(p.id) AS total_produtos,
    AVG(p.price) AS preco_medio
FROM products p
INNER JOIN categories c ON c.id = p.category_id
WHERE p.is_active = true
GROUP BY c.id, c.name
HAVING COUNT(p.id) >= 6
ORDER BY preco_medio DESC;


-- ============================================================
-- RESUMO DA AULA:
--   GROUP BY    → Agrupa registros para funções de agregação
--   HAVING      → Filtra grupos (como WHERE, mas para grupos)
--   
--   Dica de QA → Use GROUP BY para resumir dados por categoria
--                Use HAVING para encontrar grupos com anomalias
--                Use COUNT com GROUP BY para validar distribuição
--   
--   Casos de Uso → - Categorias com poucos produtos (inconsistência)
--                  - Fornecedores com preços muito acima da média
--                  - Validação de distribuição de dados
-- ============================================================