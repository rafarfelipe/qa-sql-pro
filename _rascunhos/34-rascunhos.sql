--'COUNT'

SELECT COUNT(*) AS total_produtos
FROM products;


SELECT COUNT(*) AS total_categorias
FROM categories;


SELECT 
  MIN(price) AS menor_preco,
  MAX(price) AS maior_preco,
  AVG(price) AS preco_medio,
  COUNT(*) AS total
FROM products
WHERE is_active = true;

