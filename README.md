\# Testes End-to-End – Sistema de Pontos e Caixinha



Este repositório contém os testes end-to-end da jornada do usuário no sistema de pontos e caixinha, automatizados usando \*\*Robot Framework\*\*.



\## 1. Como rodar os testes



1\. Clone o repositório:

```bash

git clone <URL\_DO\_REPOSITORIO>

cd <PASTA\_DO\_REPOSITORIO>

Instale as dependências (Python + Robot Framework):



bash

Copiar

Editar

pip install -r requirements.txt

Rodar todos os testes de uma vez:



bash

Copiar

Editar

robot Tests

A saída inclui:



log.html – detalhamento passo a passo dos testes.



report.html – resumo dos resultados.



output.xml – arquivo XML para integração ou parsing automático.



Observação: Todos os testes já incluem geração de evidências, logs do status das requisições, respostas e mensagens de erro conhecidas (WARN) quando bugs são detectados.



2\. Bugs encontrados

Durante a execução dos testes, foram identificados os seguintes bugs:



BUG-001

Descrição: API permite deletar conta já deletada sem retornar erro.

Endpoint/Teste: DELETE /account – Teste “Deletar Conta Já Deletada”

Resultado esperado: A API deveria retornar um erro (400 ou 404).

Resultado atual: Retorna 200 OK.

Impacto / Criticidade: Média a Alta – pode causar inconsistência em sistemas dependentes de status correto de conta.



BUG-002

Descrição: Extrato inicial de pontos do usuário não retorna transação inicial de +100 pontos.

Endpoint/Teste: GET /points/extrato – Teste “Extrato de Pontos Inicial”

Resultado esperado: Retornar status 200 OK com array contendo a transação inicial de +100 pontos.

Resultado atual: Array vazio, sem registrar a transação inicial.

Impacto / Criticidade: Média – impede que o histórico do usuário esteja correto desde o início.



BUG-003

Descrição: Endpoint /points/send pode não existir dependendo do ambiente.

Endpoint/Teste: POST /points/send

Resultado esperado: Status 200 OK ao enviar pontos válidos.

Resultado atual: Retorna 404 Not Found em alguns casos.

Impacto / Criticidade: Alta – bloqueia envio de pontos.



BUG-005

Descrição: API retorna erro ao tentar resgatar saldo disponível da caixinha.

Endpoint/Teste: POST /caixinha/withdraw

Resultado esperado: Retornar 200 OK quando o saldo é suficiente.

Resultado atual: Retorna 400 Bad Request.

Impacto / Criticidade: Alta – impede funcionamento da funcionalidade de saque/resgate.



Observação: Bugs 004 e 006 foram removidos ou consolidados, pois estavam duplicados ou não se aplicavam ao cenário atual.



3\. Status do sistema

Com base nos testes end-to-end:



Alguns bugs críticos e de média criticidade foram encontrados (BUG-003, BUG-005, BUG-001, BUG-002).



O sistema não está pronto para subir em produção, pois funcionalidades essenciais como envio de pontos, resgate na caixinha e extrato inicial não estão consistentes.



4\. Evidências

Todos os testes registram logs detalhados, incluindo:



Status code das respostas.



Conteúdo do corpo das respostas (JSON).



WARNs para bugs conhecidos.



Pass/Fail de cada etapa.



Exemplo de log de bug:



yaml

Copiar

Editar

🐞 BUG-002: Extrato não retornou a transação inicial de +100 pontos (saldo inconsistente)

5\. Estrutura do repositório

bash

Copiar

Editar

/Tests

&nbsp;   /account

&nbsp;       test\_delete\_account.robot

&nbsp;   /points

&nbsp;       test\_extract\_points.robot

&nbsp;       test\_send\_points.robot

&nbsp;       test\_user\_journey.robot

/resources

&nbsp;   keywords.robot

&nbsp;   variables.robot

requirements.txt

README.md

6\. Observações finais

Todos os testes são end-to-end, cobrindo cadastro, login, envio de pontos, depósito/saque na caixinha, consulta de saldo e extrato, e exclusão de conta.



Os WARNs nos logs indicam bugs conhecidos, facilitando a inspeção das falhas sem interromper a execução da suite.

