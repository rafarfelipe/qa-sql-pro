-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 08 - Manipulação de Dados para Testes
-- CONTEÚDO: UPDATE — Ajustando Dados com Segurança
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Atualizar dados com UPDATE de forma segura:
--   - Ajustar dados para cenários de teste
--   - Corrigir dados inconsistentes
--   - Preparar massa de dados controlada
--   - Validar regras de negócio com dados alterados
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — UPDATE Simples (1 registro)
-- -----------------------------------------------

-- 1.1 Atualizando um produto específico
UPDATE products
SET    
    is_active = FALSE,   
    updated_at = now()
WHERE
    id = 1020;


-- -----------------------------------------------
-- BLOCO 2 — UPDATE em Lote (faixa de IDs)
-- -----------------------------------------------

-- 2.1 Desativando vários produtos de uma vez
UPDATE products
SET    
    is_active = FALSE,   
    updated_at = now()
WHERE
    id BETWEEN 1021 AND 1026;

-- 2.2 Confirmando a atualização
SELECT name, is_active, updated_at
FROM products 
WHERE id BETWEEN 1021 AND 1026;


-- -----------------------------------------------
-- BLOCO 3 — UPDATE com Múltiplos Campos
-- -----------------------------------------------

-- 3.1 Atualizando nome e status juntos
UPDATE products
SET    
    name = 'QA-Teste01',
    is_active = true,   
    updated_at = now()
WHERE
    id BETWEEN 1021 AND 1026;

-- 3.2 Confirmando a atualização
SELECT name, is_active, updated_at
FROM products 
WHERE id BETWEEN 1021 AND 1026;


-- ============================================================
-- RESUMO:
--   UPDATE tabela SET coluna = valor WHERE condição → Atualizar registros
--   WHERE → Sempre use WHERE para evitar atualizar tudo!
--   Múltiplos campos → Separe por vírgula no SET
--   updated_at = now() → Sempre atualize a data de modificação
--   Faixa de IDs → BETWEEN valor1 AND valor2
--
--   Dica de QA → Sempre confirme com SELECT antes e depois do UPDATE
--    Use transações (BEGIN/COMMIT/ROLLBACK) em produção
--                Mantenha um registro do que foi alterado
--
--   Boas Práticas → - WHERE obrigatório (exceto quando quer atualizar tudo)
--                   - Use now() para updated_at
--                   - Teste com SELECT primeiro
-- ============================================================