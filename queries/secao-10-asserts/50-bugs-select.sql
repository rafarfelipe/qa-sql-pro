SELECT 
  'regra_nome_categoria_obrigatorio'AS teste,
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END AS status,
  COUNT(*)AS quantidade,
  STRING_AGG(id::text, ', ') AS detalhes
FROM categories
WHERE name = ''





SELECT 
  'regra_produto_tem_supplier'AS teste,
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END AS status,
  COUNT(*) AS quantidade,
  STRING_AGG(id::text, ', ') AS detalhes
FROM products
WHERE supplier_id IS NULL