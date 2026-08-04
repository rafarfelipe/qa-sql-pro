-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 10 - Asserts e Evidências Profissionais
-- CONTEÚDO: Asserts em SQL (COUNT, EXISTS e Comparações)
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Criar asserts automatizados para validar a qualidade de
--   dados usando COUNT, EXISTS e comparações.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products, categories
-- ============================================================


-- -----------------------------------------------
-- BLOCO 1 — ASSERT de Regra de Negócio
-- -----------------------------------------------

-- ASSERT: nenhum produto ativo pode ter custo maior que o preço
-- ESPERADO: 0 linhas

SELECT 
    name, 
    price, 
    cost_price
FROM products
WHERE is_active = true
  AND cost_price > price;


-- -----------------------------------------------
-- BLOCO 2 — ASSERT com COUNT e Comparação
-- -----------------------------------------------

-- ASSERT: total de produtos ativos deve ser menor que o total geral
-- lógica: sempre haverá produto inativo no banco real

SELECT
    COUNT(*) AS total_geral,
    COUNT(CASE WHEN is_active = true THEN 1 END) AS total_ativos,
    COUNT(*) > COUNT(CASE WHEN is_active = true THEN 1 END) AS assert_tem_inativos
FROM products;


-- -----------------------------------------------
-- BLOCO 3 — ASSERT de Integridade Referencial
-- -----------------------------------------------

-- ASSERT: todo produto deve ter categoria válida
-- ESPERADO: 0 linhas

SELECT 
    p.id, 
    p.name, 
    p.category_id
FROM products p
LEFT JOIN categories c ON c.id = p.category_id
WHERE c.id IS NULL;


-- -----------------------------------------------
-- BLOCO 4 — ASSERT INVERTIDO (preço inválido)
-- -----------------------------------------------

-- ASSERT INVERTIDO: nenhum produto ativo pode ter preço inválido
-- ESPERADO: 0 linhas
-- SE RETORNAR LINHAS: bug de integridade confirmado

SELECT 
    name, 
    price
FROM products
WHERE is_active = true
  AND price <= 0;


-- -----------------------------------------------
-- BLOCO 5 — ASSERT INVERTIDO (SKU duplicado)
-- -----------------------------------------------

-- ASSERT INVERTIDO: nenhum SKU pode estar duplicado
-- ESPERADO: 0 linhas

SELECT 
    sku, 
    COUNT(*) AS quantidade
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;


-- -----------------------------------------------
-- BLOCO 6 — ASSERT com EXISTS
-- -----------------------------------------------

-- ASSERT: categoria 'informatica' existe e está ativa
-- ESPERADO: true
-- use antes de rodar testes que dependem dessa categoria

SELECT EXISTS (
    SELECT 1
    FROM categories
    WHERE slug = 'informatica'
      AND is_active = true
) AS categoria_existe;


-- -----------------------------------------------
-- BLOCO 7 — NOT EXISTS (assert de ausência)
-- -----------------------------------------------

-- NOT EXISTS: assert de ausência
-- ASSERT: não existe produto com SKU duplicado
-- ESPERADO: true

SELECT NOT EXISTS (
    SELECT 1
    FROM products
    GROUP BY sku
    HAVING COUNT(*) > 1
) AS sem_sku_duplicado;


-- ============================================================
-- RESUMO:
--   COUNT      → valida volume e contagem (ex: total ativos < total geral)
--   EXISTS     → valida presença (ex: categoria informatica existe)
--   NOT EXISTS → valida ausência (ex: não há SKU duplicado)
--   LEFT JOIN  → valida integridade referencial (ex: categoria válida)
--   
--   Dica de QA → O assert ideal retorna 0 linhas ou TRUE.
--                Documente cada assert com o resultado esperado.
-- ============================================================