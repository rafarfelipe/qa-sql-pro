SELECT 
  s.company_name AS fornecedor,
  COUNT(p.id) AS total_produtos
FROM products p
INNER JOIN suppliers s ON s.id = p.supplier_id
GROUP BY s.id, s.company_name
ORDER BY total_produtos DESC;


SELECT 
  --c.name AS categoria,
  COUNT(p.id) AS total_produtos,
  AVG(p.price) AS preco_medio
FROM products p
INNER JOIN categories c ON c.id = p.category_id
WHERE p.is_active = TRUE



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


SELECT 
  c.name AS categoria,
  COUNT(p.id) AS total_produtos,
  AVG(p.price) AS preco_medio
FROM products p
INNER JOIN categories c ON c.id = p.category_id
WHERE p.is_active = true
GROUP BY c.id, c.name
HAVING COUNT(p.id) >= 6
   --AND AVG(p.price) > 100
ORDER BY preco_medio DESC;
