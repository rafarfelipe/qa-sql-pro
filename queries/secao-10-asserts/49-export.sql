-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 10 - Asserts e Evidências Profissionais
-- CONTEÚDO: Evidências Técnicas — Exportação e Reporte de Bugs
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Consolidar validações em uma única query e exportar
--   evidências para reporte de bugs:
--   - Automatizar a verificação de regras de negócio
--   - Gerar relatórios de qualidade do banco
--   - Documentar evidências para o time
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products, categories
-- ============================================================


-- -----------------------------------------------
-- BLOCO 1 — Query de Validação (Consolidada)
-- -----------------------------------------------
-- Esta query executa todas as regras de validação
-- e retorna um relatório com status PASSED/FAILED.

SELECT 
  'regra_preco_custo_valida' AS teste,
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END AS status,
  COUNT(*) AS quantidade,
  STRING_AGG(name, ', ') AS detalhes
FROM products
WHERE is_active = true AND cost_price > price

UNION ALL 

SELECT 
  'regra_existem_inativos',
  CASE 
    WHEN COUNT(*) > COUNT(CASE WHEN is_active = true THEN 1 END)
    THEN 'PASSED'
    ELSE 'FAILED'
  END,
  COUNT(*),
  NULL
FROM products

UNION ALL

SELECT 
  'regra_produto_categoria_valida',
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END,
  COUNT(*),
  STRING_AGG(p.id::text, ', ')
FROM products p
LEFT JOIN categories c ON c.id = p.category_id
WHERE c.id IS NULL

UNION ALL

SELECT 
  'regra_preco_positivo',
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END,
  COUNT(*),
  STRING_AGG(name, ', ')
FROM products
WHERE is_active = true
  AND price <= 0
  
UNION ALL

SELECT 
  'regra_sku_unico',
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END,
  COUNT(*),
  STRING_AGG(sku, ', ')
FROM (
  SELECT sku
  FROM products
  GROUP BY sku
  HAVING COUNT(*) > 1
) skus_duplicados

UNION ALL

SELECT 
  'regra_categoria_informatica_ativa' AS teste,
  CASE 
    WHEN COUNT(*) > 0 THEN 'PASSED'
    ELSE 'FAILED'
  END AS status,
  COUNT(*) AS quantidade,
  STRING_AGG(id::text, ', ') AS detalhes
FROM categories
WHERE name = 'informatica'
  AND is_active = true

UNION ALL

SELECT 
  'regra_nome_categoria_obrigatorio',
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END,
  COUNT(*),
  STRING_AGG(id::text, ', ')
FROM categories
WHERE name = ''

UNION ALL

SELECT 
  'regra_produto_tem_supplier',
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END,
  COUNT(*),
  STRING_AGG(id::text, ', ')
FROM products
WHERE supplier_id IS NULL;




-- ============================================================
-- COMO EXPORTAR EVIDÊNCIAS NO DBEAVER:
-- 1. Execute a query de validação
-- 2. Clique com botão direito no resultado
-- 3. Exportar Dados → CSV ou HTML
-- 4. Salve na pasta /evidencias
-- 5. Cole o link no relatório de bug
-- ============================================================

-- ============================================================
-- RESUMO:
--   Query Consolidada → Valida todas as regras em uma única consulta
--   Evidências Detalhadas → Queries específicas para cada defeito
--   Exportação → CSV para análise, HTML para apresentação
--   
--   Dica de QA → Mantenha um script com todas as validações
--                Execute sempre antes de um release
--                Documente os resultados no relatório de testes
-- ============================================================