-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 08 - Manipulação de Dados para Testes
-- CONTEÚDO: DELETE — Removendo Dados com Controle
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Remover dados com DELETE de forma segura e controlada:
--   - Limpar massa de teste após execução
--   - Remover dados inconsistentes
--   - Resetar cenários de teste
--   - Garantir que dados sensíveis sejam removidos corretamente
-- ============================================================
-- TABELAS UTILIZADAS:
--   - suppliers, categories
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — DELETE: Regra de Ouro
-- -----------------------------------------------
-- ⚠️ SEMPRE confirme o que vai ser deletado antes de executar o DELETE!

-- 1.1 Verificando os registros que serão afetados
SELECT id, company_name, email
FROM suppliers
WHERE company_name LIKE 'Barros Comércio%';

-- 1.2 Deletando os registros confirmados
DELETE 
FROM suppliers
WHERE company_name LIKE 'Barros Comércio%';

-- 1.3 Confirmando que foram removidos
SELECT id, company_name, email
FROM suppliers
WHERE company_name LIKE 'Barros Comércio%';


-- -----------------------------------------------
-- BLOCO 2 — DELETE com COUNT (quantos serão afetados?)
-- -----------------------------------------------

-- 2.1 Contando quantos registros serão deletados
SELECT COUNT(*) AS serao_deletados
FROM suppliers
WHERE company_name LIKE 'H%';

-- 2.2 Executando o DELETE
DELETE 
FROM suppliers
WHERE company_name LIKE 'H%';

-- 2.3 Confirmando que foram removidos
SELECT id, company_name, email
FROM suppliers
WHERE company_name LIKE 'H%';


-- -----------------------------------------------
-- BLOCO 3 — DELETE por ID (específico)
-- -----------------------------------------------

-- 3.1 Deletando uma categoria específica
DELETE 
FROM categories  
WHERE id = 4;


-- ============================================================
-- RESUMO:
--   DELETE FROM tabela WHERE condição → Remover registros
--   WHERE → Sempre use WHERE para evitar deletar tudo!
--
--   REGRA DE OURO:
--   1. SELECT antes → confirme o que será deletado
--   2. COUNT antes → saiba quantos serão afetados
--   3. DELETE depois → execute com segurança
--   4. SELECT depois → confirme que foi removido
--
--   Dica de QA → NUNCA execute DELETE sem WHERE em produção
--                Use transações (BEGIN/COMMIT/ROLLBACK)
--                Mantenha backup dos dados deletados
--
--   Boas Práticas → - SEMPRE confirme com SELECT primeiro
--                   - Use WHERE específico (ex: id = X)
--                   - Evite LIKE em produção (pode pegar mais do que espera)
--                   - Delete em lote com COUNT antes
-- ============================================================