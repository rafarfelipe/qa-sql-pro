-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 43 - Investigando Bugs com SQL na prática
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a investigar bugs usando SQL como ferramenta de 
--   investigação. O foco não é aprender comandos novos, mas sim
--   aplicar tudo que já foi visto com uma pergunta diferente:
--   "O que está errado nesse banco que a tela não está mostrando?"
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products, categories, suppliers, cart_items
-- ============================================================

-- -----------------------------------------------
-- INVESTIGAÇÃO 1: Produto Ativo sem Estoque
-- -----------------------------------------------
-- Suspeita: a loja está exibindo produtos que não têm estoque disponível.
-- Regra de negócio: produto ativo deve ter estoque > 0.
-- Se essa query retornar registros, a suspeita está confirmada.

SELECT
    p.id,
    p.name AS produto,
    p.stock_quantity AS estoque,
    p.is_active AS ativo,
    c.name AS categoria,
    s.company_name AS fornecedor
FROM products p
INNER JOIN categories c ON c.id = p.category_id
INNER JOIN suppliers s ON s.id = p.supplier_id
WHERE p.is_active = TRUE 
    AND p.stock_quantity = 0
ORDER BY c.name, p.name;


-- -----------------------------------------------
-- INVESTIGAÇÃO 2: Carrinho com Produto Inativo
-- -----------------------------------------------
-- Suspeita: existem itens no carrinho de clientes referenciando 
-- produtos que foram inativados depois da adição.
-- Regra de negócio: carrinho não deve ter produtos inativos ou sem estoque.
-- Dois cenários: produto inativado OU estoque zerado.

SELECT
    c.id AS item_carrinho,
    c.quantity AS quantidade,
    p.name AS produto,
    p.price AS preco,
    p.is_active AS produto_ativo,
    p.stock_quantity AS estoque_atual
FROM cart_items c
INNER JOIN products p ON p.id = c.product_id
WHERE p.is_active = FALSE 
    OR p.stock_quantity = 0
ORDER BY c.id;


-- ============================================================
-- RESUMO DA AULA:
--   Método de Investigação:
--   1. Qual é a suspeita? → o que o sistema deveria fazer?
--   2. Qual tabela guarda esse dado? → consultar o dicionário
--   3. Qual query confirma ou descarta? → escrever e executar
--   
--   INVESTIGAÇÃO 1: Produto ativo sem estoque
--   → Bug de regra de negócio: produto sem estoque não deveria estar ativo
--   
--   INVESTIGAÇÃO 2: Carrinho com produto inativo
--   → Bug de consistência: carrinho tem itens que não podem ser comprados
--   
--   Dica de QA: Documente o resultado — quantas linhas retornaram, 
--   quais categorias, quais fornecedores. Isso vai pro relatório.
-- ============================================================