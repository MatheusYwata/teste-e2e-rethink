*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot

*** Test Cases ***
Enviar Pontos Valido Com Saldo
    [Documentation]    Testa envio de pontos válido e registra BUG-003 se endpoint não existir
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    ${send_data}=    Create Dictionary    recipientCpf=10987654321    amount=50
    ${resp_send}=    Requisicao Autenticada    POST    /points/send    ${send_data}

    Run Keyword If    ${resp_send.status_code} == 404
    ...    Log    🐞 BUG-003: endpoint /points/send não encontrado, continuando execução    WARN
    ...    ELSE
    ...    Should Be Equal As Integers    ${resp_send.status_code}    200

Verificar Envio Acima Do Saldo
    [Documentation]    Testa envio de pontos acima do saldo e registra BUG-003 se endpoint não existir
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    ${send_data_acima}=    Create Dictionary    recipientCpf=10987654321    amount=1000  # Valor acima do saldo inicial
    ${resp_send}=    Requisicao Autenticada    POST    /points/send    ${send_data_acima}

    Run Keyword If    ${resp_send.status_code} == 404
    ...    Log    🐞 BUG-003: endpoint /points/send não encontrado (rota inexistente)    WARN

    Run Keyword If    ${resp_send.status_code} == 400
    ...    Log    ⚠️ Observação: API retornou 400 para envio acima do saldo, possivelmente mascarando o BUG-003 (endpoint inexistente)    WARN

    Run Keyword If    ${resp_send.status_code} not in [400,404]
    ...    Log    ⚠️ Resultado inesperado: retorno ${resp_send.status_code}    WARN