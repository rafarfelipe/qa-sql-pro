SELECT
    id,
    "name",
    slug,
    description,
    image_url,
    icon,
    display_order,
    is_active,
    created_at
FROM
    public.categories
LIMIT 15;

SELECT
    id,
    "name",
    slug,
    description,
    created_at
FROM
    categories
WHERE description LIKE 'Produtos%'
LIMIT 15;

SELECT
    id,
    "name",
    slug,
    description,
    created_at
FROM
    categories
WHERE description LIKE '%variados%'
LIMIT 15;

SELECT
    id,
    "name",
    slug,
    description,
    created_at
FROM
    categories
WHERE description LIKE '%variados'
LIMIT 105;

SELECT
    id,
    "name",
    slug,
    description,
    created_at
FROM
    categories
WHERE id IN (9,19,61,84)
LIMIT 105;

SELECT
    id,
    "name",
    slug,
    description,
    created_at
FROM
    categories
-- WHERE id IN (9,19,61,84)
LIMIT 105;

SELECT
    id,
    "name",
    slug,
    description,
    created_at
FROM
    categories
WHERE "name" IN ('Roupas','Pets')
LIMIT 105;

SELECT
    id,
    "name",
    slug,
    description,
    created_at
FROM
    categories
WHERE "name" NOT IN ('Roupas','Pets')
LIMIT 105;

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
LIMIT 10;

SELECT
    id,
    "name",
    slug,
    description,
    price,
    stock_quantity,
    sku,
    updated_at 
FROM
    products
  WHERE price BETWEEN 1000 AND 1300
LIMIT 10;

SELECT
    id,
    "name",
    slug,
    description,
    price,
    stock_quantity,
    sku,
    updated_at 
FROM
    products
  WHERE id BETWEEN 500 AND 550
LIMIT 10;

SELECT
    id,
    "name",
    slug,
    description,
    price,
    stock_quantity,
    sku,
    updated_at 
FROM
    products
  WHERE stock_quantity  BETWEEN -10 AND 0
LIMIT 10;
