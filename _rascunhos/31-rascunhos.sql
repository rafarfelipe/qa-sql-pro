SELECT
	p.id,
	p.category_id,
	c."name",
	p.supplier_id,	
	p."name",
	p.slug,
	p.description
FROM
	products p
INNER JOIN categories c ON c.id = p.category_id;a




SELECT
	p.id,
	p.category_id,
	c."name",
	p.supplier_id,
	s.company_name,
	p."name",
	p.slug,
	p.description
FROM
	products p
INNER JOIN categories c ON c.id = p.category_id
INNER JOIN suppliers s ON s.id =p.supplier_id  
;



SELECT
	p.id,
	p.category_id,
	c."name" categoria,
	p.supplier_id,
	s.company_name fornecedor,
	p."name",
	p.slug,
	p.description
FROM
	products p
INNER JOIN categories c ON c.id = p.category_id
INNER JOIN suppliers s ON s.id =p.supplier_id  
;


SELECT
	p.id,
	--p.category_id,
	c."name" categoria,
	--p.supplier_id,
	s.company_name fornecedor,
	p."name",
	p.slug
FROM
	products p
INNER JOIN categories c ON c.id = p.category_id
INNER JOIN suppliers s ON s.id =p.supplier_id  
;


SELECT
	p.id,
	--p.category_id,
	c."name" categoria,
	--p.supplier_id,
	s.company_name fornecedor,
	p."name",
	p.slug
FROM
	products p
INNER JOIN categories c ON c.id = p.category_id
INNER JOIN suppliers s ON s.id =p.supplier_id  
WHERE c."name" = 'Livros'
;


SELECT
	p.id,
	--p.category_id,
	c."name" AS categoria,
	--p.supplier_id,
	s.company_name AS fornecedor,
	p."name",
	p.slug
FROM
	products p
INNER JOIN categories c ON c.id = p.category_id
INNER JOIN suppliers s ON s.id =p.supplier_id  
WHERE c."name" <> 'Livros'
;

