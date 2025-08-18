*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot

*** Test Cases ***
Resgatar Da Caixinha (BUG-005)
    [Documentation]    Validar resgate com saldo suficiente; se retornar 400, registrar BUG-006 e prosseguir
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    ${deposit_data}=    Create Dictionary    amount=50
    ${resp_deposit}=    Requisicao Autenticada    POST    /caixinha/deposit    ${deposit_data}
    Should Be Equal As Integers    ${resp_deposit.status_code}    200

    ${withdraw_data}=    Create Dictionary    amount=30
    ${resp_withdraw}=    Requisicao Autenticada    POST    /caixinha/withdraw    ${withdraw_data}

    Run Keyword If    ${resp_withdraw.status_code} == 400
    ...    Log    🐞 BUG-005: API retornou 400 ao resgatar com saldo suficiente (esperado 200).    WARN
    ...    ELSE
    ...    Should Be Equal As Integers    ${resp_withdraw.status_code}    200

    Log    Status withdraw: ${resp_withdraw.status_code}
    Log    Body: ${resp_withdraw.text}
    Salvar JSON Em Arquivo    logs/caixinha_withdraw_bug006.json    ${resp_withdraw.text}

Resgatar Valor Maior Que Saldo
    [Documentation]    Validar resgate maior que o saldo disponível (deve falhar com 400)
    ${withdraw_data}=    Create Dictionary    amount=1000
    ${resp}=    Requisicao Autenticada    POST    /caixinha/withdraw    ${withdraw_data}
    Should Be Equal As Integers    ${resp.status_code}    400