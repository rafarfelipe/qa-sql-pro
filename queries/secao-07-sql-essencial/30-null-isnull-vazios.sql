-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 07 - SQL Essencial para QA (na prática)
-- AULA  : 30 - Dados Ausentes e Vazios (NULL, IS NULL, IS NOT NULL)
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Identificar campos sem valor, não preenchidos e vazios diretamente no banco — problemas que a tela esconde
--   mas o QA precisa encontrar.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products
--   - suppliers
-- ============================================================
-- CONCEITOS:
--   NULL        → ausência total de valor (campo nunca preenchido)
--   IS NULL     → filtra registros onde o campo não tem valor
--   IS NOT NULL → filtra registros onde o campo tem valor
--   ''          → string vazia (preenchido, mas com nada)
--   ' '         → string com espaço (parece preenchido, mas não é)
-- ============================================================


-- -----------------------------------------------
-- BLOCO 1 — IS NULL: encontrando campos sem valor
-- -----------------------------------------------

-- [FÁCIL] produtos sem descrição cadastrada
-- como QA: produto publicado sem descrição é dado incompleto
SELECT
  id,
  name,
  sku,
  description,
  short_description,
  image_url,
  is_active
FROM products
WHERE description IS NULL;


-- -----------------------------------------------
-- BLOCO 2 — IS NOT NULL: confirmando campos preenchidos
-- -----------------------------------------------

-- [FÁCIL] produtos que têm descrição cadastrada
-- como QA: gabarito do que deveria ser o padrão
SELECT
  id,
  name,
  sku,
  description,
  short_description,
  image_url,
  is_active
FROM products
WHERE description IS NOT NULL;


-- -----------------------------------------------
-- BLOCO 3 — String vazia: o NULL que parece preenchido
-- -----------------------------------------------

-- [INTERMEDIÁRIO] fornecedores com email vazio ('')
-- diferente de NULL: o campo foi preenchido, mas com nada
-- a tela pode exibir como "em branco" — no banco são problemas diferentes
SELECT
  id,
  company_name,
  contact_name,
  contact_title,
  email
FROM suppliers
WHERE email = '';

-- ============================================================
-- RESULTADO ESPERADO:
--   WHERE description IS NULL     → produtos sem descrição
--   WHERE description IS NOT NULL → produtos com descrição
--   WHERE email = ''              → fornecedores com email vazio
-- ============================================================
-- ATENÇÃO:
--   NULL != '' (string vazia) != ' ' (espaço)
--   São três problemas diferentes — cada um com seu filtro.
--   Nunca use WHERE campo = NULL — sempre IS NULL ou IS NOT NULL.
-- ============================================================