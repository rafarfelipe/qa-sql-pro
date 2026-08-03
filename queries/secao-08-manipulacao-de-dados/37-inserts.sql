-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 08 - Manipulação de Dados para Testes
-- AULA  : 37 - INSERT: criando massa de teste do zero
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Aprender a inserir dados com INSERT para criar massa de teste.
--   Para QAs, isso é essencial para:
--   - Preparar dados controlados para testes
--   - Popular tabelas com dados válidos
--   - Criar cenários de teste específicos
--   - Validar regras de negócio com dados próprios
-- ============================================================
-- TABELAS UTILIZADAS:
--   - categories, products
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — INSERT Simples (1 registro)
-- -----------------------------------------------

-- 1.1 Inserindo uma nova categoria
INSERT INTO categories
("name", slug, description, is_active, created_at) 
VALUES
('Teste', 'teste', 'Teste de Insert', TRUE, now());

-- 1.2 Confirmando o que foi inserido
SELECT id, name, slug, is_active
FROM categories
WHERE slug IN ('teste');


-- -----------------------------------------------
-- BLOCO 2 — INSERT com Múltiplos Registros
-- -----------------------------------------------

-- 2.1 Inserindo várias categorias de uma vez
INSERT INTO categories
("name", slug, description, is_active, created_at) 
VALUES
('Teste Duplo1', 'teste-duplo1', 'Teste de Insert novo1', false, now()),
('Teste Duplo2', 'teste-duplo2', 'Teste de Insert novo2', true, now()),
('Teste Duplo3', 'teste-duplo3', 'Teste de Insert novo3', false, now()),
('Teste Duplo4', 'teste-duplo4', 'Teste de Insert novo4', true, now()),
('Teste Duplo5', 'teste-duplo5', 'Teste de Insert novo5', false, now()),
('Teste Duplo6', 'teste-duplo6', 'Teste de Insert novo6', true, now()),
('Teste Duplo7', 'teste-duplo7', 'Teste de Insert novo7', false, now());

-- 2.2 Confirmando os registros inseridos
SELECT id, name, slug, is_active
FROM categories
WHERE slug LIKE 'teste-dupl%';


-- -----------------------------------------------
-- BLOCO 3 — INSERT com ON CONFLICT (evita duplicidade)
-- -----------------------------------------------

-- 3.1 Inserindo categorias reais (ignora se já existir)
INSERT INTO categories
("name", slug, description, is_active, created_at) 
VALUES
('Eletrônicos', 'eletronicos', 'Produtos eletrônicos em geral', true, now()),
('Roupas Masculinas', 'roupas-masculinas', 'Vestuário para o público masculino', true, now()),
('Roupas Femininas', 'roupas-femininas', 'Vestuário para o público feminino', true, now()),
('Calçados', 'calcados', 'Sapatos, tênis e sandálias', true, now()),
('Acessórios', 'acessorios', 'Acessórios diversos para uso pessoal', true, now()),
('Beleza e Cosméticos', 'beleza-cosmeticos', 'Produtos de beleza e cuidados pessoais', true, now()),
('Esportes', 'esportes', 'Artigos esportivos e fitness', true, now()),
('Casa e Decoração', 'casa-decoracao', 'Itens para casa e decoração', true, now()),
('Móveis', 'moveis', 'Móveis para todos os ambientes', true, now()),
('Brinquedos', 'brinquedos', 'Brinquedos para todas as idades', true, now()),
('Livros', 'livros', 'Livros de diversos gêneros', true, now()),
('Alimentos', 'alimentos', 'Produtos alimentícios variados', true, now()),
('Bebidas', 'bebidas', 'Bebidas alcoólicas e não alcoólicas', false, now()),
('Pet Shop', 'pet-shop', 'Produtos para animais de estimação', true, now()),
('Automotivo', 'automotivo', 'Acessórios e peças automotivas', true, now())
ON CONFLICT (slug) DO NOTHING;


-- -----------------------------------------------
-- BLOCO 4 — INSERT com Chaves Estrangeiras (FK)
-- -----------------------------------------------

-- 4.1 Estrutura básica (com valores fixos)
INSERT INTO products
(category_id, supplier_id, "name", slug, description, price, stock_quantity, sku, is_active, reviews_count, created_at)
VALUES
(0, 0, '', '', '', 0, 0, '', TRUE, 0, now());

-- 4.2 Inserindo produtos com IDs reais de categorias e fornecedores
INSERT INTO products
(category_id, supplier_id, "name", slug, description, price, stock_quantity, sku, is_active, reviews_count, created_at)
VALUES
(26, 18, 'Produto QA 01', 'produto-qa-01', 'Produto de teste QA 01', 99.90, 10, 'SKU-001', TRUE, 0, now()),
(268, 21, 'Produto QA 02', 'produto-qa-02', 'Produto de teste QA 02', 149.90, 20, 'SKU-002', TRUE, 5, now()),
(114, 8, 'Produto QA 03', 'produto-qa-03', 'Produto de teste QA 03', 59.90, 15, 'SKU-003', TRUE, 2, now()),
(118, 22, 'Produto QA 04', 'produto-qa-04', 'Produto de teste QA 04', 199.90, 5, 'SKU-004', TRUE, 10, now()),
(121, 17, 'Produto QA 05', 'produto-qa-05', 'Produto de teste QA 05', 29.90, 50, 'SKU-005', TRUE, 1, now()),
(123, 38, 'Produto QA 06', 'produto-qa-06', 'Produto de teste QA 06', 79.90, 30, 'SKU-006', TRUE, 3, now()),
(126, 25, 'Produto QA 07', 'produto-qa-07', 'Produto de teste QA 07', 89.90, 25, 'SKU-007', TRUE, 4, now()),
(128, 26, 'Produto QA 08', 'produto-qa-08', 'Produto de teste QA 08', 119.90, 12, 'SKU-008', TRUE, 6, now()),
(26, 27, 'Produto QA 09', 'produto-qa-09', 'Produto de teste QA 09', 39.90, 40, 'SKU-009', TRUE, 0, now()),
(268, 28, 'Produto QA 10', 'produto-qa-10', 'Produto de teste QA 10', 249.90, 8, 'SKU-010', TRUE, 8, now()),
(114, 30, 'Produto QA 11', 'produto-qa-11', 'Produto de teste QA 11', 19.90, 60, 'SKU-011', TRUE, 0, now()),
(118, 31, 'Produto QA 12', 'produto-qa-12', 'Produto de teste QA 12', 299.90, 3, 'SKU-012', TRUE, 12, now()),
(121, 18, 'Produto QA 13', 'produto-qa-13', 'Produto de teste QA 13', 54.90, 22, 'SKU-013', TRUE, 2, now()),
(123, 21, 'Produto QA 14', 'produto-qa-14', 'Produto de teste QA 14', 134.90, 18, 'SKU-014', TRUE, 7, now()),
(126, 8, 'Produto QA 15', 'produto-qa-15', 'Produto de teste QA 15', 74.90, 35, 'SKU-015', TRUE, 1, now())
ON CONFLICT (slug) DO NOTHING;

-- 4.3 Confirmando os produtos inseridos
SELECT id, name, slug, price, stock_quantity
FROM products
WHERE slug LIKE 'produto-qa-%'
ORDER BY id;


-- ============================================================
-- RESUMO DA AULA:
--   INSERT INTO tabela (colunas) VALUES (valores) → Inserir registros
--   Múltiplos VALUES → Inserir vários registros de uma vez
--   ON CONFLICT (coluna) DO NOTHING → Evita duplicidade
--   Chaves Estrangeiras (FK) → Inserir IDs que existem em outras tabelas
--   
--   Dica de QA → Sempre confirme o INSERT com SELECT
--                Use ON CONFLICT para evitar erros em massa de teste
--                Mantenha os IDs das FKs válidos (ex: category_id, supplier_id)
--   
--   Boas Práticas → - Use now() para created_at
--                   - Prefira TRUE/FALSE para is_active
--                   - Evite inserir dados sem validar FKs primeiro
-- ============================================================