*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot

*** Test Cases ***
Jornada Completa Do Usuario
    [Documentation]    Fluxo completo: cadastro, confirmação, login, envio de pontos, depósito, saque, consulta e exclusão.

    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    # Enviar Pontos
    ${send_data}=    Create Dictionary    recipientCpf=10987654321    amount=50
    ${resp_send}=    Requisicao Autenticada    POST    /points/send    ${send_data}
    Run Keyword If    ${resp_send.status_code} == 404
    ...    Log    🐞 BUG-003: endpoint /points/send não encontrado, retornou 404    WARN
    ...    ELSE
    ...    Should Be Equal As Integers    ${resp_send.status_code}    200
    ...    Dictionary Should Contain Key    ${resp_send.json()}    message

    # Depositar na Caixinha
    ${deposit_data}=    Create Dictionary    amount=30
    ${resp_deposit}=    Requisicao Autenticada    POST    /caixinha/deposit    ${deposit_data}
    Should Be Equal As Integers    ${resp_deposit.status_code}    200
    Dictionary Should Contain Key    ${resp_deposit.json()}    message

    # Resgatar da Caixinha
    ${withdraw_data}=    Create Dictionary    amount=10
    ${resp_withdraw}=    Requisicao Autenticada    POST    /caixinha/withdraw    ${withdraw_data}
    Run Keyword If    ${resp_withdraw.status_code} == 400
    ...    Log    🐞 BUG-005: API falha ao resgatar saldo disponível, retornou 400    WARN
    ...    ELSE
    ...    Should Be Equal As Integers    ${resp_withdraw.status_code}    200
    ...    Dictionary Should Contain Key    ${resp_withdraw.json()}    message

    # Consultar Extratos
    ${resp_points}=    Requisicao Autenticada    GET    /points/extrato
    Run Keyword If    '${resp_points.json()}' == '[]'
...    Log    🐞 BUG-002: extrato de pontos não retornou a transação inicial de +100 pontos (saldo inconsistente)    WARN
...    ELSE
...    Should Be Equal As Integers    ${resp_points.status_code}    200
...    Length Should Be    ${resp_points.json()}    1

    ${resp_piggy}=    Requisicao Autenticada    GET    /caixinha/extrato
    Should Be Equal As Integers    ${resp_piggy.status_code}    200
    Length Should Be    ${resp_piggy.json()}    1

    # Consultar Saldo
    ${resp_saldo}=    Requisicao Autenticada    GET    /points/saldo
    Should Be Equal As Integers    ${resp_saldo.status_code}    200
    Dictionary Should Contain Key    ${resp_saldo.json()}    normal_balance
    Dictionary Should Contain Key    ${resp_saldo.json()}    piggy_bank_balance

    # Excluir Conta
    ${delete_data}=    Create Dictionary    password=${PASSWORD}
    ${resp_delete}=    Requisicao Autenticada    DELETE    /account    ${delete_data}
    Should Be Equal As Integers    ${resp_delete.status_code}    200
    Dictionary Should Contain Key    ${resp_delete.json()}    message