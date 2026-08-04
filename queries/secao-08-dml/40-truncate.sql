-- ============================================================
-- PROJETO : SQL & Banco de Dados para QA
-- MÓDULO  : 08 - Manipulação de Dados para Testes
-- CONTEÚDO: TRUNCATE — Quando Usar (vs DELETE)
-- BANCO  : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Usar TRUNCATE para remover todos os dados de uma tabela:
--   - Limpar massa de teste rapidamente
--   - Resetar tabelas entre cenários de teste
--   - Remover todos os dados de forma controlada
--   - Entender a diferença entre DELETE e TRUNCATE
-- ============================================================
-- TABELAS UTILIZADAS:
--   - addresses
-- ============================================================

-- -----------------------------------------------
-- BLOCO 1 — DELETE por ID (específico)
-- -----------------------------------------------

-- 1.1 Removendo um endereço específico
DELETE
FROM
    public.addresses
WHERE
    id = 3;


-- -----------------------------------------------
-- BLOCO 2 — TRUNCATE: Remove TODOS os dados
-- -----------------------------------------------

-- 2.1 TRUNCATE zera a tabela inteira instantaneamente
-- ⚠️ NÃO RODE ISSO EM PRODUÇÃO SEM CERTEZA ABSOLUTA
TRUNCATE TABLE addresses;

-- 2.2 TRUNCATE com CASCADE (remove dados de tabelas relacionadas)
-- ⚠️ NÃO RODE ISSO EM PRODUÇÃO SEM CERTEZA ABSOLUTA
TRUNCATE TABLE addresses CASCADE;

-- 2.3 TRUNCATE com RESTART IDENTITY (reinicia a sequência de IDs)
TRUNCATE TABLE addresses RESTART IDENTITY CASCADE;


-- -----------------------------------------------
-- BLOCO 3 — INSERT: Criando massa de teste
-- -----------------------------------------------

-- 3.1 Inserindo um endereço simples
INSERT INTO public.addresses
(user_id, address_type, "label", street, "number", complement, neighborhood, city, state, zip_code, country, is_default, created_at)
VALUES
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', '', '', '', '', '', '', '', '', 'Brazil', FALSE, now());

-- 3.2 Inserindo múltiplos endereços (massa de teste)
INSERT INTO public.addresses
(user_id, address_type, "label", street, "number", complement, neighborhood, city, state, zip_code, country, is_default, created_at)
VALUES
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Trabalho', 'Av. Paulista', '1500', 'Sala 45', 'Bela Vista', 'São Paulo', 'SP', '01310-200', 'Brazil', FALSE, now()),
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Casa Praia', 'Rua do Sol', '77', 'Casa', 'Praia Grande', 'Santos', 'SP', '11000-000', 'Brazil', FALSE, now()),
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Casa Pais', 'Rua Oliveira', '890', '', 'Jardim América', 'Rio de Janeiro', 'RJ', '22000-000', 'Brazil', FALSE, now()),
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Outro', 'Av. Brasil', '500', 'Bloco B', 'Centro', 'Curitiba', 'PR', '80000-000', 'Brazil', FALSE, now());


-- ============================================================
-- COMPARAÇÃO: DELETE vs TRUNCATE
-- ============================================================
-- 
--   DELETE                             |   TRUNCATE
--   -----------------------------------|-----------------------------------
--   Remove registros com WHERE         |   Remove TODOS os registros
--   Pode ser desfeito com ROLLBACK     |   Pode ser desfeito com ROLLBACK
--   Mais lento (registro por registro) |   MUITO mais rápido
--   Mantém a sequência (ID)            |   Reinicia a sequência (ID)
--   Dispara triggers                   |   NÃO dispara triggers
--   Libera espaço aos poucos           |   Libera espaço imediatamente
--   Pode usar WHERE                    |   NÃO pode usar WHERE
-- ============================================================

-- RESUMO:
--   DELETE FROM tabela WHERE condição → Remove registros específicos
--   TRUNCATE TABLE tabela → Remove TODOS os registros
--   TRUNCATE CASCADE → Remove dados de tabelas relacionadas
--   TRUNCATE RESTART IDENTITY → Reinicia a sequência de IDs
--
--   Dica de QA → Use DELETE para remover dados específicos
--                Use TRUNCATE para limpar massa de teste rapidamente
--                NUNCA use TRUNCATE em produção sem autorização
--                Sempre confirme antes de executar TRUNCATE
--
--   Boas Práticas → - DELETE com WHERE específico
--                   - TRUNCATE apenas em ambiente de teste
--                   - Use CASCADE com cuidado
--                   - Mantenha backup antes de TRUNCATE
-- ============================================================