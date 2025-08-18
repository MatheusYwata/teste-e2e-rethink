*** Settings ***
Documentation     Testes de login da API Points
Resource          ../../resources/keywords.robot
Resource          ../../resources/variables.robot
Library           RequestsLibrary

*** Test Cases ***
Login Com Credenciais Válidas
    [Documentation]    Deve permitir login com e-mail e senha válidos
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    ${payload}=    Create Dictionary    email=${EMAIL}    password=${PASSWORD}
    ${response}=   POST On Session    banking    /login    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200
    Log    ${response.json()}

Login Com Senha Incorreta
    [Documentation]    Deve falhar ao tentar login com senha incorreta
    Criar Sessao API
    ${payload}=    Create Dictionary    email=${EMAIL}    password=SenhaErrada
    ${response}=   POST On Session    banking    /login    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400
    Log    ${response.json()}

Login Com Email Inexistente
    [Documentation]    Deve falhar ao tentar login com e-mail não cadastrado
    Criar Sessao API
    ${payload}=    Create Dictionary    email=emailnaoexiste@teste.com    password=Senha123!
    ${response}=   POST On Session    banking    /login    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400
    Log    ${response.json()}

*** Keywords ***
Criar Sessao API
    [Documentation]    Cria a sessão para acessar a API
    Create Session    banking    ${BASE_URL}    verify=${False}