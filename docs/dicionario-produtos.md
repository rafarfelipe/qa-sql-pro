# Dicionário de Dados — PRODUTOS

> Documento vivo — atualizar sempre que uma regra de negócio mudar.  
> Versão: 1.0 | Sprint: [1] | Atualizado em: [02/08/2026]

---

## Entidade: [Products / Orders / Users / ...]

| Campo | Tipo (banco) | Obrigatório | Mín / Máx | Formato / Padrão | Unicidade | Relacionamento | Mensagem de erro esperada | Observações |
|---|---|---|---|---|---|---|---|---|
| name | VARCHAR(255) | ✅ | 6 / 40 | Sem números, sem especiais, sem espaços duplos | ✅ Único | — | "Nome é obrigatório" / "Mínimo 6 caracteres" / "Máximo 40 caracteres" / "Não pode conter números" | Banco permite 255 — margem intencional para escalabilidade. Regra atual da API: 40. |
| price | DECIMAL(10,2) | ✅ | > 0 / 999999.99 | Número positivo | ❌ | — | "Preço é obrigatório" / "Deve ser um valor positivo" | — |
| stock | INTEGER | ✅ | 1 / 999 | Apenas inteiros | ❌ | — | "Estoque é obrigatório" / "Apenas números de 1 a 999" | — |
| sku | VARCHAR(50) | ✅ | 5 / 20 | Maiúsculas + números + hífen. Começa com letra maiúscula. | ✅ Único | — | "SKU é obrigatório" / "Deve ter entre 5 e 20 caracteres" / "Apenas letras maiúsculas, números e hífen" / "Deve começar com letra maiúscula" | — |
| slug | VARCHAR(255) | ❌ | — | Gerado automaticamente a partir do name se não informado | ✅ Único | — | "Já existe um produto com esse nome/slug" | Campo opcional com comportamento: se não enviado, API gera automaticamente. |
| category_id | INTEGER | ✅ | — | ID existente na tabela categories | ❌ | FK → categories.id | "Categoria selecionada não existe. Escolha uma categoria válida." | Validação de existência obrigatória — banco não restringe, API valida. |
| supplier_id | INTEGER | ✅ | — | ID existente na tabela suppliers | ❌ | FK → suppliers.id | "Fornecedor selecionado não existe. Escolha um fornecedor válido." | Idem category_id. |

---

## Regras de Negócio (além do tipo do campo)

| # | Regra | Comportamento esperado |
|---|---|---|
| RN01 | Nome duplicado não permitido | API retorna erro de duplicidade |
| RN02 | SKU duplicado não permitido | API retorna erro de duplicidade |
| RN03 | category_id deve existir | API valida existência antes de salvar |
| RN04 | supplier_id deve existir | API valida existência antes de salvar |
| RN05 | slug gerado automaticamente | Se não informado, gerado a partir do name |
| RN06 | Campos opcionais aceitam null | API não rejeita ausência de campos não obrigatórios |

---

## Gaps e Apontamentos

| Campo | Gap identificado | Ação sugerida |
|---|---|---|
| name | Banco: VARCHAR(255) / API: maxLength 40 — desalinhados | Verificar se é intencional (escalabilidade) ou débito técnico. Sugerir constraint no banco ou documentar intenção. |
| sku | Pattern não está documentado no Swagger | Sugerir ao time adicionar `pattern` no schema do Swagger |

---

## Histórico de Alterações

| Sprint | Data | Campo alterado | De | Para | Motivo |
|---|---|---|---|---|---|
| 01 | [02/08/2026] | — | — | — | Criação inicial |

---

> **Como usar este documento:**  
> 1. Cada linha da tabela = pelo menos 1 cenário de teste (caminho feliz + caminho de erro)  
> 2. Gaps identificados = apontamentos para o time (dev, AR, PO)  
> 3. Atualizar o histórico sempre que uma regra mudar — mesmo que a mudança venha de uma nova sprint