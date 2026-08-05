![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![DBeaver](https://img.shields.io/badge/DBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-0078D7?style=for-the-badge&logo=azuredevops&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)

# 🗄️ SQL & Banco de Dados para QA

> Projeto **SQL & Banco de Dados para QA** — validar dados direto na fonte, investigar bugs que a tela esconde e documentar evidências no padrão de mercado.

---

## ✅ O que foi feito

- ✅ Suite de testes SQL com PASSED/FAILED automatizado
- 🔍 Investigações de bugs direto no banco (API vs Banco)
- 🐛 Bug reports documentados no padrão de mercado
- 📊 Relatórios HTML publicados via GitHub Pages

---

## 🛠️ Stack & Ferramentas

- **Banco:** PostgreSQL (Supabase)
- **Cliente SQL:** DBeaver (queries, asserts, exports)
- **Versionamento:** Git + GitHub (branches, PRs, GitHub Pages)
- **Gestão:** Azure DevOps (boards, pipelines)
- **Linguagem:** SQL (DQL, DML, DDL, transações)
- **Metodologia:** Testes exploratórios, asserts automatizados, bug reports padronizados

---

## 📊 Relatórios ao Vivo

> 🔗 [Relatório de Categorias](https://rafarfelipe.github.io/qa-sql-pro/queries/secao-11-IA-acelerador/relatorio-categorias.html)
> 🔗 [Relatório de Fornecedores](https://rafarfelipe.github.io/qa-sql-pro/queries/secao-11-IA-acelerador/relatorio-fornecedores.html)

---

## 🧪 Suite de Testes

| Teste | Status |
|---|---|
| regra_preco_custo_valida | ✅ PASSED |
| regra_existem_inativos | ✅ PASSED |
| regra_produto_categoria_valida | ✅ PASSED |
| regra_preco_positivo | ✅ PASSED |
| regra_sku_unico | ✅ PASSED |
| regra_categoria_informatica_ativa | ❌ FAILED |
| regra_nome_categoria_obrigatorio | ❌ FAILED |
| regra_produto_tem_supplier | ❌ FAILED |

---

## 📈 Cobertura da Suíte

| Categoria | Regras Validadas |
|---|---|
| Integridade de dados | preco_custo_valida, preco_positivo, sku_unico |
| Relacionamentos | produto_categoria_valida, produto_tem_supplier |
| Catálogo | categoria_informatica_ativa, nome_categoria_obrigatorio |
| Soft delete | existem_inativos |

---

## 🔍 Investigações Realizadas

| ID | Investigação | Status | Evidência |
|---|---|---|---|
| INV-001 | Produto sem fornecedor vinculado | 🔴 Bug confirmado | [ver](./relatorio-de-execucao/evidencias/figura-2-bug001-assert-failed.PNG) |
| INV-002 | Categoria com nome vazio/nulo | 🔴 Bug confirmado | [ver](./relatorio-de-execucao/evidencias/figura-1-suite-resultado.PNG) |

---

## 📁 Estrutura do Projeto

```
qa-sql-pro/
├── queries/
│   ├── secao-07-sql-essencial/
│   ├── secao-08-dml/
│   ├── secao-09-qa-investigativo/
│   ├── secao-10-asserts/
│   ├── secao-11-IA-acelerador/
│   └── inserts-especificos/
├── docs/
│   ├── architecture.md
│   ├── dicionario-produtos.md
│   └── guia-dbeaver.md
├── relatorio-de-execucao/
│   ├── relatorio-executivo.md
│   └── evidencias/
├── utils/
│   └── dump-postgres-202606300850.sql
└── README.md
```

---

## ▶️ Como Reproduzir Localmente

1. Provisionar PostgreSQL (Supabase ou Docker local)
2. Restaurar o dump: `psql -f utils/dump-postgres-202606300850.sql`
3. Abrir `relatorio-de-execucao/evidencias/suite-de-testes.sql` no DBeaver
4. Executar bloco a bloco — resultado na aba `Result`

---

## 📚 Documentação Técnica

Consulte a pasta [`/docs`](docs/) para:
dicionário de dados, guia de referência do DBeaver
e arquitetura do projeto.

---

## 👤 Autor

**Rafael Felipe**
Formação: SQL & Banco de Dados para QA

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/rafaelrfelipe)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/rafarfelipe)
