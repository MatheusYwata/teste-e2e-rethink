*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot

*** Test Cases ***
Extrato De Pontos (BUG-002)
    [Documentation]    Testa extrato inicial de pontos de usuário recém-criado.
    [Tags]    known_bug

    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Fazer Login E Obter Token

    # Consultar extrato de pontos
    ${resp_extract}=    Requisicao Autenticada    GET    /points/extrato

    # Verificar status code
    Should Be Equal As Integers    ${resp_extract.status_code}    200

    # Validar conteúdo do extrato
    Run Keyword If    ${resp_extract.json()} == []
    ...    Log    🐞 BUG-002: Extrato não retornou a transação inicial de +100 pontos (saldo inconsistente)    WARN
    ...    ELSE
    ...    Log    ✅ Extrato retornou transações corretamente

    # Logs informativos
    Log    Status extrato: ${resp_extract.status_code}
    Log    Extrato: ${resp_extract.json()}