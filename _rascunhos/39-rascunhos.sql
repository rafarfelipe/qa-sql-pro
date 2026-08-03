Barros Comércio_1777765955292

-- SEMPRE confirma antes
SELECT id, company_name, email
FROM suppliers
WHERE company_name LIKE 'Barros Comércio%'

-- só depois deleta
DELETE 
FROM suppliers
WHERE company_name LIKE 'Barros Comércio%'


SELECT id, company_name, email
FROM suppliers
WHERE company_name LIKE 'Barros Comércio%'


-- quantos serão afetados?
SELECT COUNT(*) AS serao_deletados
FROM suppliers
WHERE company_name LIKE 'H%'

DELETE 
FROM suppliers
WHERE company_name LIKE 'H%'

SELECT id, company_name, email
FROM suppliers
WHERE company_name LIKE 'H%'


DELETE 
FROM categories  
WHERE id = 4






