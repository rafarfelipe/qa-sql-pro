-- produtos com preço acima da média


SELECT AVG(price) FROM products


SELECT 
    id,
    name,
    price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;



SELECT price FROM products WHERE category_id = 20

-- produtos mais caros que qualquer produto da categoria 1
SELECT 
    id,
    name,
    price
FROM products
WHERE price > ALL (SELECT price FROM products WHERE category_id = 20)
ORDER BY price DESC;



-- produtos com média de avaliações (tratando NULL)
SELECT 
    p.id,
    p.name AS produto,
    p.price,    
        (SELECT AVG(r.rating) 
         FROM reviews r 
         WHERE r.product_id = p.id),
        0
     AS media_avaliacao
FROM products p
ORDER BY media_avaliacao DESC;


SELECT 
    p.id,
    p.name AS produto,
    p.price,
    COALESCE(
        (SELECT AVG(r.rating) 
         FROM reviews r 
         WHERE r.product_id = p.id),
        0
    ) AS media_avaliacao
FROM products p
ORDER BY media_avaliacao DESC;


-- categorias que têm produtos
SELECT 
    c.id,
    c.name AS categoria
FROM categories c
WHERE  EXISTS (
    SELECT 1 
    FROM products p 
    WHERE p.category_id = c.id
);


SELECT 
    c.id,
    c.name AS categoria
FROM categories c
WHERE NOT EXISTS (
    SELECT 1 
    FROM products p 
    WHERE p.category_id = c.id
);







