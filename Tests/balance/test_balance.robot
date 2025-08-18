*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot

*** Test Cases ***
Consultar Saldo Geral
    [Documentation]    Deve permitir que um usuário autenticado consulte seu saldo
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${resp}=       GET On Session    banking    /points/saldo    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=       Set Variable    ${resp.json()}
    Should Contain    ${json.keys()}    normal_balance
    Should Contain    ${json.keys()}    piggy_bank_balance


Consultar Saldo Sem Autenticacao
    [Documentation]    Não deve permitir consulta de saldo sem autenticação
    Criar Sessao API

    ${resp}=    GET On Session    banking    /points/saldo    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401


Consultar Saldo Com Token Invalido
    [Documentation]    Não deve permitir consulta de saldo com token inválido
    Criar Sessao API

    ${headers}=    Create Dictionary    Authorization=Bearer 123456tokenInvalido
    ${resp}=       GET On Session    banking    /points/saldo    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401