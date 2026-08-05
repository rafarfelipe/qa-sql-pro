# 📊 Relatório de Execução — Suite de Testes SQL

**Projeto:** SQL & Banco de Dados para QA  
**Banco:** Supabase Northwind (PostgreSQL)  
**Data de execução:** 2026-08-05  
**Executado por:** Rafael Felipe  
**Script:** [`Suite de Testes em SQL`](suite-de-testes.sql)

---

## 📊 Resultado Consolidado

| Métrica | Valor |
|---------|-------|
| **Total de Testes** | 8 |
| **Aprovados (PASSED)** | 5 ✅ |
| **Retificados (FAILED)** | 3 ❌ |
| **Alertas (WARNING)** | 0 ⚠️ |
| **Percentual de Acerto** | 62.50% |

---

## 📋 Tabela de Resultados

| # | Teste | Status | Qtde | Detalhes |
|---|-------|--------|------|----------|
| 01 | regra_preco_custo_valida | ✅ PASSED | 0 | — |
| 02 | regra_existem_inativos | ✅ PASSED | 384 | — |
| 03 | regra_produto_categoria_valida | ✅ PASSED | 0 | — |
| 04 | regra_preco_positivo | ✅ PASSED | 0 | — |
| 05 | regra_sku_unico | ✅ PASSED | 0 | — |
| 06 | regra_categoria_informatica_ativa | ❌ FAILED | 0 | — |
| 07 | regra_nome_categoria_obrigatorio | ❌ FAILED | 9 | IDs: 676,677,678,679,680,681,682,683,684 |
| 08 | regra_produto_tem_supplier | ❌ FAILED | 12 | IDs: 935,936,937,938,939,940,941,351,369,408,237,782 |

---

## ✅ Testes que Passaram (5/8)

Todos os 5 testes abaixo retornaram **PASSED** — regras de negócio respeitadas.

| Teste | O que valida |
|-------|--------------|
| regra_preco_custo_valida | Nenhum produto ativo com price < cost_price |
| regra_existem_inativos | Banco possui produtos inativos (soft delete ativo) |
| regra_produto_categoria_valida | Todos os produtos têm categoria válida |
| regra_preco_positivo | Nenhum produto ativo com preço zero ou negativo |
| regra_sku_unico | Nenhum SKU duplicado no banco |

---

## ❌ Testes que Falharam (3/8)

### BUG-001 — regra_categoria_informatica_ativa

**Título:** `[DATABASE] Categoria 'informatica' não está ativa`

**Critério Avaliado:**
A categoria 'informatica' deve estar ativa para fins de navegação e filtros da loja.

**Premissa/Entendimento:**
A categoria 'informatica' é uma categoria importante para a navegação da loja e deve estar ativa para que os produtos dessa categoria sejam exibidos.

**Defeito:**
1. Categoria 'informatica' não está ativa no momento da execução

**Query executada:**
```sql
SELECT 
  'regra_categoria_informatica_ativa' AS teste,
  CASE WHEN COUNT(*) > 0 THEN 'PASSED' ELSE 'FAILED' END AS status,
  COUNT(*) AS quantidade,
  STRING_AGG(id::text, ', ') AS detalhes
FROM categories
WHERE name = 'informatica' AND is_active = true
```

**Resultado obtido:** `FAILED` — 0 categorias 'informatica' ativas encontradas

**Evidência da execução:**
> ![Figura 1 — Resultado da Suite de Testes no DBeaver](../evidencias/figura-1-suite-resultado.PNG)  
> *Figura 1 — Output com categoria 'informatica' inativa*

**Resultado Esperado vs Atual:**

| Expectativa | Atual |
|-------------|-------|
| PASSED — Pelo menos 1 categoria 'informatica' ativa | 0 categorias 'informatica' ativas |

**Risco:**
1. Produtos da categoria 'informatica' não exibidos na loja
2. Filtros de navegação quebrados
3. Experiência do usuário prejudicada

---

### BUG-002 — regra_nome_categoria_obrigatorio

**Título:** `[DATABASE] Categoria cadastrada com nome nulo ou vazio`

**Critério Avaliado:**
Toda categoria deve ter o campo `name` obrigatoriamente preenchido — é exibido na navegação da loja e usado em filtros da API.

**Premissa/Entendimento:**
O formulário de cadastro de categoria deveria validar o campo `name` como obrigatório antes de persistir no banco. Categorias com nome vazio ou nulo tornam-se invisíveis ou quebram a navegação da loja.

**Defeito:**
1. Sistema permitiu salvar categoria com `name = NULL` ou `name = ''`
2. Validação de obrigatoriedade ausente no backend

**Query executada:**
```sql
SELECT 
  'regra_nome_categoria_obrigatorio' AS teste,
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END AS status,
  COUNT(*) AS quantidade,
  STRING_AGG(id::text, ', ') AS detalhes
FROM categories
WHERE name = ''
```

**Resultado obtido:** `FAILED` — 10 registros encontrados

**Evidência da execução:**
> ![Figura 2 — Assert FAILED regra_nome_categoria_obrigatorio](../evidencias/figura-2-bug002-assert-failed.png)  
> *Figura 2 — Output mostrando categorias com nome vazio (IDs: 91,701,702,704,706,708,710,711,712,713)*

**Resultado Esperado vs Atual:**

| Expectativa | Atual |
|-------------|-------|
| PASSED — 0 categorias com `name IS NULL` ou `TRIM(name) = ''` | 10 categorias com nome inválido persistidas no banco |

**Risco:**
1. Categoria exibida sem nome na loja — experiência do usuário comprometida
2. Filtros e integrações que dependem do campo `name` podem quebrar
3. Relatórios de categoria com dados inconsistentes

---

### BUG-003 — regra_produto_tem_supplier

**Título:** `[DATABASE] Produto ativo cadastrado sem fornecedor vinculado`

**Critério Avaliado:**
Todo produto ativo deve ter `supplier_id` válido e não nulo — obrigatório para rastreabilidade de fornecedor e reposição de estoque.

**Premissa/Entendimento:**
A regra de negócio impede que um produto seja publicado sem estar vinculado a um fornecedor. O campo `supplier_id` é chave estrangeira obrigatória no cadastro de produto.

**Defeito:**
1. Sistema permitiu salvar produto ativo com `supplier_id = NULL`
2. Validação de obrigatoriedade ausente no formulário de cadastro
3. Constraint `NOT NULL` ausente na coluna `supplier_id`

**Query executada:**
```sql
SELECT 
  'regra_produto_tem_supplier' AS teste,
  CASE WHEN COUNT(*) = 0 THEN 'PASSED' ELSE 'FAILED' END AS status,
  COUNT(*) AS quantidade,
  STRING_AGG(id::text, ', ') AS detalhes
FROM products
WHERE supplier_id IS NULL
```

**Resultado obtido:** `FAILED` — 12 registros encontrados

**Evidência da execução:**
> ![Figura 3 — Assert FAILED regra_produto_tem_supplier](../evidencias/figura-3-bug003-assert-failed.PNG)  
> *Figura 3 — Output mostrando produtos sem fornecedor (IDs: 935,936,937,938,939,940,941,351,369,408,237,782)*

**Resultado Esperado vs Atual:**

| Expectativa | Atual |
|-------------|-------|
| PASSED — 0 produtos com `supplier_id IS NULL` | 12 produtos ativos sem fornecedor vinculado |

**Risco:**
1. Produto publicado sem rastreabilidade de fornecedor
2. Impossibilidade de acionar reposição automática de estoque
3. Relatórios de fornecedor com volume de produtos incorreto

---

## 📋 Ações Sugeridas

| Bug | Ação Imediata | Ação Preventiva |
|-----|---------------|-------------------|
| BUG-001 | Ativar categoria 'informatica' | Verificar processo de ativação de categorias |
| BUG-002 | Preencher nome das categorias afetadas | Validar `name NOT NULL` no formulário |
| BUG-003 | Vincular produtos ao fornecedor correto | Adicionar `NOT NULL constraint` na coluna |

---

## 📅 Histórico e Próximas Ações

| Data | Ação |
|------|------|
| 2026-08-05 | Suite executada — 5 PASSED, 3 FAILED |
| 2026-08-05 | BUG-001, BUG-002 e BUG-003 identificados |
| — | BUG-001 corrigido |
| — | BUG-002 corrigido |
| — | BUG-003 corrigido |
| — | Re-execução da suite — todos PASSED |

---

*Projeto: [SQL & Banco de Dados para QA](../README.md)*