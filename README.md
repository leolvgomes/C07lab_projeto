# Projeto de Banco de Dados - C07

## Integrantes do Grupo

* Gabriel Westin Generoso Pontes - 635/L2
* Leonardo Oliveira Gomes - 662/L2

## Tema Escolhido: Sistema de Gestão Comercial Imobiliária

**Explicação do Tema:** O projeto consiste na modelagem de um banco de dados para um sistema imobiliário focado em agilizar o trabalho de corretores e facilitar o agendamento de clientes. O sistema mapeia os imóveis disponíveis e gerencia a carteira de cada corretor, além da hierarquia entre corretores e seus gerentes. Também controla um histórico de agendamento de visitas (relacionamento N:M) que permite monitorar quais clientes visitaram quais propriedades. Por fim, o modelo gerencia a formalização de contratos de venda/aluguel, garantindo a integridade dos dados e a associação correta entre o imóvel negociado, o cliente e o corretor responsável.

---

## Estrutura do repositório

| Arquivo | Conteúdo |
|---|---|
| `projeto_bd.mwb` | Modelo do banco no MySQL Workbench (1ª entrega) |
| `script_imobiliaria.sql` | Script completo da 2ª entrega: criação do banco, dados, DML, usuários/role, function, procedure, view, trigger e consultas |
| `README.md` | Documentação do projeto |

## Como executar

1. Abra o MySQL Workbench (MySQL 8.0 ou superior) conectado com um usuário administrador (ex.: `root`), pois o script cria usuários e roles.
2. Abra o arquivo `script_imobiliaria.sql`.
3. Execute o script inteiro (raio ⚡). Ele apaga e recria o banco `projeto_imobiliaria`, então pode ser executado quantas vezes for preciso.

> O script desliga o `SQL_SAFE_UPDATES` no início e religa no final, porque o modo seguro do Workbench bloqueia alguns `UPDATE`/`DELETE` usados na seção de DML.

---

## Modelo do banco

| Tabela | Descrição |
|---|---|
| `corretor` | Corretores da imobiliária. O campo `idgerente` aponta para outro corretor (autorrelacionamento). |
| `cliente` | Clientes interessados, com CPF, telefone e limite de crédito aprovado. |
| `imovel` | Imóveis da carteira (Casa, Apartamento ou Terreno), cada um sob responsabilidade de um corretor. |
| `contrato` | Formalização da venda/aluguel de um imóvel para um cliente. |
| `agenda_visita` | Tabela associativa com o histórico de visitas (Agendada, Realizada ou Cancelada). |

### Relacionamentos

| Tipo | Tabelas | Como é garantido |
|---|---|---|
| **1:1** | `contrato` ↔ `imovel` | `UNIQUE` em `contrato.idImovel`: um imóvel só pode ter um contrato. |
| **1:N** | `corretor` → `imovel` | Um corretor tem vários imóveis; cada imóvel tem um único corretor. |
| **1:N** (recursivo) | `corretor` (gerente) → `corretor` | Um gerente coordena vários corretores. `ON DELETE SET NULL`. |
| **1:N** | `cliente` → `contrato` | Um cliente pode assinar vários contratos. |
| **N:M** | `cliente` ↔ `imovel` | Resolvido pela tabela `agenda_visita`. `ON DELETE CASCADE` nas duas FKs. |

---

## 2ª Entrega

### 1. Script SQL do modelo (DDL)

O script recria fielmente o modelo da 1ª entrega: mesmas tabelas, tipos (`DECIMAL(12,2)`, `ENUM`, `CHAR(11)` etc.), chaves primárias, chaves estrangeiras com as regras `ON DELETE`/`ON UPDATE` e índices `UNIQUE` (`creci` e `contrato.idImovel`).

### 2. Inserção dos dados

Todas as tabelas recebem **pelo menos 5 registros** (dados fictícios da região de Itajubá e Santa Rita do Sapucaí):

| Tabela | Registros inseridos | Registros no final do script |
|---|---|---|
| `corretor` | 6 (2 gerentes + 4 corretores) | 6 |
| `cliente` | 7 | 6 (um é excluído na seção de DML) |
| `imovel` | 9 | 9 |
| `contrato` | 5 | 6 (um novo é criado no teste do trigger) |
| `agenda_visita` | 13 | 12 |

A ordem dos `INSERT` respeita as chaves estrangeiras: primeiro as tabelas referenciadas (`corretor`, `cliente`), depois as que dependem delas.

### 3. Comandos DML e o motivo de cada um

| Comando | O que faz | Motivo |
|---|---|---|
| `UPDATE imovel` | Reajusta em 5% o valor dos imóveis **sem contrato** | A imobiliária atualiza o preço da carteira disponível; imóveis já negociados não podem mudar de valor, por isso a subconsulta `NOT IN (SELECT idImovel FROM contrato)`. |
| `UPDATE cliente` (limite) | Aumenta o limite de crédito de um cliente | O banco aprovou um financiamento maior. Esse limite é usado pelo trigger que valida contratos. |
| `UPDATE cliente` (telefone) | Corrige o telefone de um cliente | Atualização cadastral comum. |
| `UPDATE corretor` | Muda o gerente de uma corretora | Transferência de equipe: basta alterar a chave do autorrelacionamento. |
| `DELETE FROM agenda_visita` | Remove visitas **canceladas** que já passaram | Limpeza da agenda: essas visitas não têm valor para o histórico comercial. |
| `DELETE FROM cliente` | Exclui um cliente sem contrato | Pedido de exclusão de dados (LGPD). As visitas dele são apagadas junto pelo `ON DELETE CASCADE`. |
| `SELECT` | Confere o resultado das alterações | Validar que os comandos tiveram o efeito esperado. |

### 4. Usuários e ROLE

Foi criada a role **`role_corretor`** com as permissões `SELECT`, `INSERT`, `UPDATE` e `EXECUTE` no banco `projeto_imobiliaria`. Ela é concedida aos dois usuários:

* `usr_leonardo@localhost`
* `usr_gabriel@localhost`

**Por quê:** em vez de dar permissão usuário por usuário, as permissões ficam na role. Se a regra mudar, basta alterar a role e todos os corretores são atualizados. O corretor pode consultar, cadastrar, alterar e executar as rotinas (procedure/function), mas **não pode apagar registros** (`DELETE`) nem alterar a estrutura do banco. O `SET DEFAULT ROLE` faz a role ficar ativa automaticamente no login.

Teste feito: logado como `usr_leonardo`, o `SELECT` funciona e o `DELETE` retorna `ERROR 1142: DELETE command denied`.

### 5. Function, Procedure, View e Trigger

#### Function `fn_calcula_comissao(valor)`
Retorna a comissão do corretor (6% do valor fechado). **Por quê:** o cálculo aparece em vários relatórios (view de contratos e consulta de carteira). Centralizar numa função evita repetir a conta e, se a porcentagem mudar, só a função precisa ser alterada.

#### Procedure `sp_agendar_visita(idCliente, idImovel, data)`
Agenda uma visita depois de validar as regras de negócio:
* o cliente e o imóvel precisam existir;
* o imóvel não pode já ter contrato;
* a data precisa ser no futuro;
* não pode existir outra visita agendada no mesmo imóvel e horário.

**Por quê:** um `INSERT` simples não verifica essas regras. Com a procedure, o corretor só faz `CALL sp_agendar_visita(...)` e o banco garante a consistência da agenda, devolvendo uma mensagem de erro clara (`SIGNAL SQLSTATE '45000'`) quando alguma regra é violada.

#### View `vw_contratos_detalhados`
Junta `contrato`, `imovel`, `cliente` e `corretor` e mostra o valor anunciado, o valor fechado e a comissão. **Por quê:** é o relatório mais usado e exige 4 tabelas; a view deixa a consulta pronta (`SELECT * FROM vw_contratos_detalhados`) e esconde dados sensíveis do cliente, como CPF e limite de crédito.

#### Trigger `trg_valida_contrato` (BEFORE INSERT em `contrato`)
Bloqueia contratos com valor menor ou igual a zero ou acima do limite de crédito do cliente. **Por quê:** a regra fica no próprio banco, então vale para qualquer aplicação ou usuário que tente inserir um contrato.

### 6. Consultas com JOIN

| Consulta | Relacionamento | O que mostra |
|---|---|---|
| 6.1 | **1:1** `contrato` ↔ `imovel` | Cada contrato com seu imóvel e o desconto negociado (%) em relação ao valor anunciado. |
| 6.2 | **1:N** `corretor` → `imovel` | Carteira de cada corretor: nº de imóveis, nº fechados, valor total e comissão total (`LEFT JOIN` + `GROUP BY`). |
| 6.3 | **1:N recursivo** `corretor` → `corretor` | Equipes de cada gerente (`SELF JOIN`). |
| 6.4 | **N:M** `cliente` ↔ `imovel` | Histórico completo de visitas com corretor e se a visita virou contrato (4 `JOIN`s + `CASE`). |
| 6.5 | **N:M** com agregação | Taxa de conversão de visitas realizadas em contratos, por corretor. |
| 6.6 | **N:M** + subconsulta | Clientes que visitaram imóveis mas ainda não fecharam contrato (leads para retomar). |

---

## Implementações extras

| Extra | Descrição e motivo |
|---|---|
| Function `fn_total_visitas(idImovel)` | Conta as visitas não canceladas de um imóvel; indica a procura pelo imóvel. |
| View `vw_imoveis_disponiveis` | "Vitrine" com os imóveis ainda sem contrato, o corretor responsável e o nº de visitas. |
| Trigger `trg_cancela_visitas_apos_contrato` (AFTER INSERT em `contrato`) | Quando um imóvel é vendido/alugado, cancela automaticamente as visitas que ainda estavam agendadas para ele, mantendo a agenda atualizada. |
| Transação (`START TRANSACTION` / `ROLLBACK`) | Demonstra que operações podem ser desfeitas por completo: um reajuste é aplicado dentro da transação e desfeito com `ROLLBACK`. |
| Índice composto `idx_imovel_tipo_valor` | Acelera a busca mais comum ("tipo de imóvel + faixa de preço"); o `EXPLAIN` mostra que a consulta passa a usar o índice. |
| Testes automáticos dos objetos | O script chama a procedure, consulta as views e insere um contrato para mostrar os triggers funcionando. Os casos de erro estão comentados no script para quem quiser testar. |

---

## Checklist da entrega

- [x] Script SQL do modelo (banco e tabelas)
- [x] Mínimo de 5 registros por tabela
- [x] Comandos DML com explicação do motivo
- [x] Dois usuários relacionados por uma ROLE
- [x] Consultas com JOIN nos relacionamentos 1:1, 1:N e N:M
- [x] Procedure, View, Trigger e Function, com justificativa
- [x] Extras documentados