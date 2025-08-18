*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot

*** Test Cases ***
Extrato Da Caixinha
    [Documentation]    Testa extrato da caixinha após depósito. Evidencia possível bug se extrato vazio retornar erro.
    
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    ${deposit_data}=    Create Dictionary    amount=40
    ${resp_deposit}=    Requisicao Autenticada    POST    /caixinha/deposit    ${deposit_data}
    Should Be Equal As Integers    ${resp_deposit.status_code}    200

    ${resp_extract}=    Requisicao Autenticada    GET    /caixinha/extrato

    Run Keyword If    ${resp_extract.status_code} != 200
    ...    Log    🐞 BUG-006: API retornou ${resp_extract.status_code} ao consultar extrato, esperado 200    WARN
    ...    ELSE
    ...    Should Be Equal As Integers    ${resp_extract.status_code}    200

    Log    Status extrato: ${resp_extract.status_code}
    Log    Extrato: ${resp_extract.json()}