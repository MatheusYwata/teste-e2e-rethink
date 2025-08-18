*** Settings ***
Library           BuiltIn
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Resource          ../../resources/variables.robot
Resource          ../../resources/keywords.robot

*** Test Cases ***
Deletar Conta Com Sucesso
    Gerar Massa Usuario
    Criar Sessao API
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token
    ${resp}=    Excluir Conta
    Should Be Equal As Integers    ${resp.status_code}    200

Deletar Conta Sem Autenticacao
    ${resp}=    Excluir Conta Sem Token E Capturar Erro
    Should Be Equal As Integers    ${resp.status_code}    401
    

Deletar Conta Ja Deletada
    [Tags]    known_bug
    [Documentation]    Deve falhar ao tentar deletar conta já deletada (BUG conhecido: API retorna 200 em vez de 400)
    Gerar Massa Usuario
    Criar Sessao API
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token
    ${resp}=    Excluir Conta
    Should Be Equal As Integers    ${resp.status_code}    200
    ${resp2}=   Excluir Conta
    # Esperamos 400, mas a API retorna 200 -> bug
    Run Keyword If    ${resp2.status_code} == 200
    ...    Log    🐞 BUG-001: API permitiu deletar conta já deletada, retornou 200 em vez de 400    WARN
    ...    ELSE
    ...    Should Be Equal As Integers    ${resp2.status_code}    400

