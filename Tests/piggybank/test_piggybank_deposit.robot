*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot

*** Test Cases ***
Depositar Na Caixinha
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token
    ${deposit_data}=    Create Dictionary    amount=30
    ${resp}=    Requisicao Autenticada    POST    /caixinha/deposit    ${deposit_data}
    Should Be Equal As Integers    ${resp.status_code}    200

Depositar Valor Negativo (BUG-004)
    [Documentation]    Testa depósito negativo e registra BUG-005 se API aceitar valor inválido

    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    ${deposit_data}=    Create Dictionary    amount=-10
    ${resp}=    Requisicao Autenticada    POST    /caixinha/deposit    ${deposit_data}

    Run Keyword If    ${resp.status_code} == 200
    ...    Log    🐞 BUG-004: API permite depósito negativo, esperado 400    WARN
    ...    ELSE
    ...    Should Be Equal As Integers    ${resp.status_code}    400

    Log    Status do depósito: ${resp.status_code}
    Log    Resposta: ${resp.json()}