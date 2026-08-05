---
name: Architecture
Descrição: Visão geral da estrutura do repositório e organização das queries
---

# Arquitetura do Projeto

O repositório `qa-sql-pro` é estruturado de forma a separar responsabilidades e facilitar a manutenção e a reprodução de testes de banco de dados. Abaixo apresentamos a visão geral destes componentes e seu relacionamento.

## Estrutura de Diretórios

```
├── docs/                     # Documentação geral
│   └── architecture.md       # Este arquivo – visão de alto nível
├── utils/                    # Scripts utilitários
│   └── dump-postgres-202606300850.sql
├── queries/                  # Todos os scripts SQL
│   ├── secao-07-sql-essencial/          # Conceitos e manipulação de dados
│   ├── secao-08-dml/                     # Operações de DML (INSERT, UPDATE, DELETE)
│   ├── secao-09-qa-investigativo/      # Rastreio e investigação de problemas
│   ├── secao-10-asserts/                # Assertos de qualidade e validações
│   └── inserts-especificos/             # Inserções específicas por módulo
└── relatorio-de-execucao/   # Evidências geradas após a execução
    └── evidencias/          # Relatórios, screenshots, CSVs
```

### `utils`
Contém scripts que auxiliam na utilidade do ambiente de teste, como a `dump-postgres-202606300850.sql` – um `dump` de um banco de dados de referência para que o projeto possa ser executado localmente ou em CI.

### `queries`
É o núcleo do projeto. Cada sub‑pasta representa um domínio funcional: 

| Sub‑pasta | Descrição |
|---|---|
| `secao-07-sql-essencial` | Conceitos de SQL fundamental (joins, agregações, etc.) |
| `secao-08-dml` | Operações de escrita e manipulação de dados |
| `secao-09-qa-investigativo` | Scripts voltados à investigação de inconsistências e divergências |
| `secao-10-asserts` | Regra de negócio e validações de qualidade de dados |
| `inserts-especificos` | Scripts de inserção pré‑configurada para testes assertivos |

Todos os scripts têm origem em `INSERT`, `SELECT`, `UPDATE` ou `DELETE` – não há lógica programática em outras linguagens. Isso facilita a execução direta em qualquer cliente SQL compatible com PostgreSQL.

### `relatorio-de-execucao`
Armazena os artefatos gerados a partir da execução de queries de assert. Perfeita para reportar bugs ou métricas de qualidade. Visando reprodutibilidade, documentos como `suite-de-testes.sql` já consolidam todas as regras num único arquivo que pode ser executado e exportado para CSV/HTML via DBeaver.

## Fluxo de Execução

1. **Preparação** – Carregar o `dump-postgres-202606300850.sql` em um banco de dados de teste.  
2. **Execução das queries** – Usar o script `suite-de-testes.sql` (ou outros específicos) para validar regras de negócio.  
3. **Exportação de evidências** – Usar DBeaver ou `COPY` para gerar CSV/HTML.  
4. **Armazenamento** – Salvar artefatos em `relatorio-de-execucao/evidencias/`.  
5. **Revisão** – O arquivo `docs/architecture.md` serve de referência para QA e recrutadores entenderem rapidamente a estrutura.

## Práticas Recomendadas

- Mantenha os scripts PADRONIZADOS: nome‑ação/descritivo (`insert_produtos.sql`, `assert_produto_preco.sql`).  
- Use `ANALYZE` após criar índices novos para manter estatísticas atualizadas.  
- Documente qualquer alteração em `docs/architecture.md` para garantir que outras pessoas compreendam as mudanças.

---

_Este guia tem como objetivo oferecer uma visão clara do panorama de códigos e pastas dentro do repositório para recrutadores e novos colaboradores._