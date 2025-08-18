*** Settings ***
Library           BuiltIn
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary


*** Keywords ***

Criar Sessao API
    Create Session    banking    ${BASE_URL}

Gerar Massa Usuario
    ${cpf}=       Evaluate    ''.join([str(__import__('random').randint(0,9)) for _ in range(11)])    modules=random
    ${email}=     Evaluate    f'teste_{__import__("random").randint(1000,9999)}@example.com'
    ${full_name}=  Set Variable    João da Silva

    # Tornar variáveis globais para todos os Test Cases
    Set Suite Variable    ${CPF}        ${cpf}
    Set Suite Variable    ${EMAIL}      ${email}
    Set Suite Variable    ${FULL_NAME}  ${full_name}
    Set Suite Variable    ${PASSWORD}   Senha@123

Cadastrar Usuario
    ${payload}=    Create Dictionary
    ...    cpf=${CPF}
    ...    full_name=${FULL_NAME}
    ...    email=${EMAIL}
    ...    password=${PASSWORD}
    ...    confirmPassword=${PASSWORD}
    ${resp}=       POST On Session    banking    url=/cadastro    json=${payload}
    Set Suite Variable    ${CONFIRM_TOKEN}    ${resp.json()["confirmToken"]}

Confirmar Email
    ${resp}=    GET On Session    banking    url=/confirm-email?token=${CONFIRM_TOKEN}
    Should Be Equal As Integers    ${resp.status_code}    200

Fazer Login E Obter Token
    ${payload}=    Create Dictionary
    ...    email=${EMAIL}
    ...    password=${PASSWORD}
    ${resp}=       POST On Session    banking    url=/login    json=${payload}
    Set Suite Variable    ${TOKEN}    ${resp.json()["token"]}

Enviar Pontos
    [Arguments]    ${recipientCpf}    ${amount}
    ${payload}=    Create Dictionary
    ...    recipientCpf=${recipientCpf}
    ...    amount=${amount}
    ${resp}=       POST On Session    banking    url=/points/send    json=${payload}    headers=${{"Authorization": "Bearer ${TOKEN}"}}
    Should Be Equal As Integers    ${resp.status_code}    200

Extrato Pontos
    ${resp}=    GET On Session    banking    url=/points/extrato    headers=${{"Authorization": "Bearer ${TOKEN}"}}
    RETURN    ${resp.json()}

Depositar Caixinha
    [Arguments]    ${amount}
    ${payload}=    Create Dictionary
    ...    amount=${amount}
    ${resp}=       POST On Session    banking    url=/caixinha/deposit    json=${payload}    headers=${{"Authorization": "Bearer ${TOKEN}"}}
    Should Be Equal As Integers    ${resp.status_code}    200

Resgatar Caixinha
    [Arguments]    ${amount}
    ${payload}=    Create Dictionary
    ...    amount=${amount}
    ${resp}=       POST On Session    banking    url=/caixinha/withdraw    json=${payload}    headers=${{"Authorization": "Bearer ${TOKEN}"}}
    Should Be Equal As Integers    ${resp.status_code}    200

Extrato Caixinha
    ${resp}=    GET On Session    banking    url=/caixinha/extrato    headers=${{"Authorization": "Bearer ${TOKEN}"}}
    RETURN    ${resp.json()}


Salvar JSON Em Arquivo
    [Arguments]    ${filepath}    ${json_content}
    Create File    ${filepath}    ${json_content}

Criar Sessao E Obter Token
    [Documentation]    Faz login e retorna o token do usuário criado
    ${payload}=    Create Dictionary    email=${EMAIL}    password=${PASSWORD}
    ${response}=   POST On Session    banking    /login    json=${payload}
    RETURN    ${response.json()['token']}

Excluir Conta
    ${payload}=    Create Dictionary    password=${PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${resp}=       DELETE On Session    banking    url=/account    json=${payload}    headers=${headers}
    RETURN    ${resp}

Excluir Conta Sem Token
    [Documentation]    Tenta excluir a conta sem fornecer token de autenticação
    ${payload}=    Create Dictionary    password=${PASSWORD}
    ${resp}=       DELETE On Session    banking    url=/account    json=${payload}
    RETURN    ${resp}

Excluir Conta Com Senha
    [Arguments]    ${senha}
    [Documentation]    Exclui a conta do usuário autenticado usando a senha fornecida
    ${payload}=    Create Dictionary    password=${senha}
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}
    ${resp}=       DELETE On Session    banking    url=/account    json=${payload}    headers=${headers}
    RETURN    ${resp}

Excluir Conta Sem Token E Capturar Erro
    ${payload}=    Create Dictionary    password=${PASSWORD}
    ${resp}=       DELETE On Session    banking    /account    json=${payload}    expected_status=401
    RETURN    ${resp}

Requisitar Saldo
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${resp}=    GET On Session    banking    /points/saldo    headers=${headers}
    RETURN    ${resp}

Requisitar Saldo Sem Autenticacao
    ${resp}=    GET On Session    banking    /points/saldo
    RETURN    ${resp}


Requisicao Autenticada
    [Arguments]    ${method}    ${endpoint}    ${data}=None
    ${headers}=    Create Dictionary    Authorization=Bearer ${TOKEN}    Content-Type=application/json
    ${resp}=    Evaluate    requests.request('${method}', '${BASE_URL}${endpoint}', headers=${headers}, json=${data} if ${data} != None else None)    modules=requests
    RETURN    ${resp}

Registrar Bug
    [Arguments]    ${bug_id}    ${descricao}
    Append To File    ../../logs/bugs.log    ${bug_id} :: ${descricao}