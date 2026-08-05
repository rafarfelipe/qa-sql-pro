# 📋 Explicação Técnica — Query de Auditoria Northwind

## Visão Geral

Esta query é uma ferramenta de auditoria completa que consolida informações de **produtos**, **estoque**, **fornecedores** e **categoria** com métricas de desempenho como **avaliações de clientes**, **itens no carrinho**, **pedidos** e **receita total**. O resultado é um relatório de uma linha por produto com status visual de disponibilidade, ordenado pelo faturamento gerado, permitindo identificação rápida de produtos críticos para o negócio.

---

## SELECT — Colunas e Cálculos

### Campos Diretos de `products`

```sql
p.id, p.name, p.sku, p.price, p.cost_price,
p.stock_quantity, p.reorder_level, p.is_active,
p.is_featured, p.discount_percentage
```

| Campo | Propósito |
|-------|-----------|
| `p.id` | Identificador único |
| `p.name` | Nome descritivo do produto |
| `p.sku` | Código de barras/usuario |
| `p.price` | Preço de venda |
| `p.cost_price` | Custo de aquisição |
| `p.stock_quantity` | Estoque atual |
| `p.reorder_level` | Nível de reposição |
| `p.is_active` | Status de ativação |
| `p.is_featured` | Produto em destaque |
| `p.discount_percentage` | Desconto aplicado |

---

### Cálculos de Margem e Preço Final

#### `margem`

```sql
(p.price - p.cost_price)::numeric(10,2) AS margem
```

- **Cálculo:** Diferença entre preço de venda e custo
- **Formatação:** `::numeric(10,2)` para 2 casas decimais
- **Uso QA:** Identificar produtos com margem negativa (prejuízo)

#### `preco_final`

```sql
(p.price * (1 - COALESCE(p.discount_percentage,0) / 100))::numeric(10,2) AS preco_final
```

- **Cálculo:** Preço com desconto aplicado
- **COALESCE:** Trata `NULL` como `0%` (produtos sem desconto)
- **Uso QA:** Validar se preços com desconto estão corretos

---

### Dados de Fornecedor e Categoria

```sql
c.name           AS categoria,
c.is_active      AS categoria_ativa,
s.company_name   AS fornecedor,
s.email          AS email_fornecedor,
s.city           AS cidade_fornecedor,
s.is_active      AS fornecedor_ativo
```

- **Objetivo:** Contextualizar o produto com sua cadeia de valor
- **Uso QA:** Verificar consistência de fornecedores/categorias

---

### Métricas de Negócio (Agregações)

```sql
COUNT(r.id)                     AS total_avaliacoes,
AVG(r.rating)::numeric(3,1)     AS media_avaliacao,
COUNT(ci.id)                    AS vezes_no_carrinho,
COUNT(oi.id)                    AS total_pedidos,
SUM(oi.subtotal)::numeric(10,2) AS receita_total
```

| Métrica | Tipo | Uso QA |
|---------|------|--------|
| `total_avaliacoes` | Contagem | Produtos com baixa avaliação |
| `media_avaliacao` | Média | Identificar produtos de baixa qualidade |
| `vezes_no_carrinho` | Contagem | Interesse dos clientes |
| `total_pedidos` | Contagem | Popularidade |
| `receita_total` | Soma | Faturamento por produto |

---

## JOINs — Como as Tabelas se Conectam

### INNER JOIN (Relacionamentos Obligatórios)

```sql
INNER JOIN categories c ON c.id = p.category_id
INNER JOIN suppliers  s ON s.id = p.supplier_id
```

| Característica | INNER JOIN | LEFT JOIN |
|----------------|------------|-----------|
| Requer relacionamento | Sim | Não |
| Exclui registros sem match | Sim | Não |
| Uso neste caso | Dados inconsistentes não podem aparecer | |

**Racional:** Um produto sem categoria ou fornecedor é dado inconsistente. INNER JOIN garante integridade referencial.

### LEFT JOIN (Relacionamentos Opcionais)

```sql
LEFT JOIN reviews     r  ON r.product_id  = p.id
LEFT JOIN cart_items  ci ON ci.product_id = p.id
LEFT JOIN order_items oi ON oi.product_id = p.id
```

| Tabela | Por que LEFT JOIN |
|--------|-------------------|
| `reviews` | Produtos novos podem não ter avaliações |
| `cart_items` | Produtos podem nunca ter sido adicionados ao carrinho |
| `order_items` | Produtos podem ser incomercializados |

**Risco:** Cruzamento simultâneo gera duplicação de linhas. As agregações (COUNT, SUM) podem incluir registros duplicados de outras tabelas.

---

## GROUP BY e Agregações

### Estrutura do GROUP BY

```sql
GROUP BY p.id, p.name, p.sku, p.price, p.cost_price,
         p.stock_quantity, p.reorder_level, p.is_active,
         p.is_featured, p.discount_percentage,
         c.name, c.is_active,
         s.company_name, s.email, s.city, s.is_active
```

**Regra PostgreSQL:** Toda coluna não-agregada no SELECT deve estar no GROUP BY.

### Considerações sobre Agregações

```sql
COUNT(r.id)    -- Conta NULL como 0
AVG(r.rating)  -- Média aritmética
SUM(subtotal)  -- Soma total
```

**Validação QA:** Para evitar inflação por JOINs múltiplos:
```sql
COUNT(DISTINCT r.id) AS total_avaliacoes
COUNT(DISTINCT ci.id) AS vezes_no_carrinho
```

---

## CASE WHEN — Classificações de Status

### `status_estoque`

```sql
CASE
  WHEN p.stock_quantity = 0           THEN '🔴 SEM ESTOQUE'
  WHEN p.stock_quantity <= p.reorder_level THEN '🟡 ESTOQUE CRÍTICO'
  ELSE '🟢 OK'
END AS status_estoque
```

| Condição | Emoji | Classificação |
|----------|-------|---------------|
| Quantidade = 0 | 🔴 | Critically out of stock |
| Quantidade ≤ mínimo | 🟡 | Reorder needed |
| Outro | 🟢 | In stock |

**Ordem importa:** Zero é verificado antes do limite mínimo.

### `status_geral`

```sql
CASE
  WHEN p.is_active = false  THEN '❌ INATIVO'
  WHEN c.is_active = false  THEN '⚠️ CATEGORIA INATIVA'
  WHEN s.is_active = false  THEN '⚠️ FORNECEDOR INATIVO'
  ELSE '✅ DISPONÍVEL'
END AS status_geral
```

| Condição | Emoji | Significado |
|----------|-------|-------------|
| Produto inativo | ❌ | Descontinuado |
| Categoria inativa | ⚠️ | Produto não listado |
| Fornecedor inativo | ⚠️ | Sem suporte |
| Todos OK | ✅ | Disponível para venda |

**Prioridade:** Produto inativo tem prioridade sobre fatores indiretos.

---

## ORDER BY

```sql
ORDER BY receita_total DESC NULLS LAST
```

| Componente | Efeito |
|------------|--------|
| `receita_total DESC` | Do maior para o menor faturamento |
| `NULLS LAST` | Produtos sem vendas vão para o fim |

**Importância QA:** Mantém foco nos produtos mais críticos financeiramente.

---

## Como Usar Esta Query

### Casos de Uso para QA

1. **Verificação de Integridade**
   - Confirmar que produtos sem categoria/fornecedor não aparecem
   - Validar INNER JOIN contra regras de negócio

2. **Testes de Performance**
   - Produtos novos sem histórico: deve aparecer com zeros
   - Validar `preco_final` com `COALESCE` para produtos sem desconto

3. **Validação de Agrupamento**
   - Comparar contagens isoladas vs. query completa
   - Identificar inflação por JOINs múltiplos

4. **Testes de Negócio**
   - `stock_quantity = 0` + `reorder_level = 0`: deve retornar "SEM ESTOQUE"
   - Produto inativo com categoria/fornecedor ativos: "INATIVO" tem prioridade

5. **Análise de Tendências**
   - Produtos com `media_avaliacao` baixa: investigar qualidade
   - `vezes_no_carrinho` alto + `total_pedidos` baixo: candengueio

---

## Pontos de Atenção

| Issue | Risco | Solução QA |
|-------|-------|------------|
| JOINs múltiplos | Contagens infladas | Usar `COUNT(DISTINCT ...)` |
| Valores NULL | Classificações erradas | Usar `COALESCE` em cálculos |
| Ordem do CASE | Status incorreto | Verificar lógica de prioridade |
| NULLS no ORDER BY | Produtos sem venda no topo | Sempre usar `NULLS LAST` |