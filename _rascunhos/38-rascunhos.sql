UPDATE  products
SET    
    is_active = FALSE,   
    updated_at = now()
WHERE
    id = 1020;


UPDATE  products
SET    
    is_active = FALSE,   
    updated_at = now()
WHERE
    id BETWEEN 1021 AND 1026;


SELECT "name", is_active, updated_at
FROM products 
WHERE id BETWEEN 1021 AND 1026;


UPDATE  products
SET    
"name"= 'QA-Teste01',
is_active = true,   
    updated_at = now()
WHERE
    id BETWEEN 1021 AND 1026;


SELECT "name", is_active, updated_at
FROM products 
WHERE id BETWEEN 1021 AND 1026;

