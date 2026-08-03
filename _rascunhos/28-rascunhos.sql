SELECT
    id,
    category_id,
    supplier_id,
    "name",
    slug,
    description,
    short_description,
    price,
    cost_price,
    stock_quantity,
    reorder_level,
    image_url,
    sku,
    barcode,
    weight,
    is_active,
    is_featured,
    discount_percentage,
    rating,
    reviews_count,
    views_count,
    sales_count,
    created_at,
    updated_at
FROM
    public.products
LIMIT 15;

SELECT
    id,
    category_id,
    "name",
    price,
    cost_price,
    is_active
FROM
    public.products
WHERE category_id = 13
LIMIT 25;

SELECT
    id,
    category_id,
    "name"
FROM
    public.products
WHERE category_id <> 13
ORDER BY category_id
LIMIT 100;

SELECT
    id,
    category_id,
    "name"
FROM
    public.products
WHERE category_id <> 13
ORDER BY category_id DESC
LIMIT 100;

SELECT
    id,
    category_id,
    "name"
FROM
    public.products
WHERE category_id <> 13
ORDER BY "name" ASC
LIMIT 100;

SELECT
    id,
    category_id,
    "name"
FROM
    public.products
WHERE category_id > 13
ORDER BY "name" ASC
LIMIT 200;

SELECT
    id,
    category_id,
    "name",
    price
FROM
    products
WHERE category_id > 13
AND price > 1234
ORDER BY price 
LIMIT 25;

SELECT
    id,
    category_id,
    "name",
    price
FROM
    products
WHERE category_id > 13
AND price > 1234
ORDER BY category_id DESC,price ASC  
LIMIT 25;