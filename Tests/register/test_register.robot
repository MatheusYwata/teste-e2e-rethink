*** Settings ***
Resource    ../../resources/variables.robot
Resource    ../../resources/keywords.robot
Library     BuiltIn
Library     Collections

*** Test Cases ***
Cadastro Com Dados Válidos
    [Documentation]    Testa cadastro de usuário com dados válidos
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    Should Not Be Empty    ${CONFIRM_TOKEN}

Cadastro Com Email Existente
    [Documentation]    Testa cadastro de usuário com email já existente, esperando erro 400
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    # Tentando cadastrar novamente com mesmo email
    ${payload}=    Create Dictionary
    ...    cpf=${CPF}
    ...    full_name=${FULL_NAME}
    ...    email=${EMAIL}
    ...    password=${PASSWORD}
    ...    confirmPassword=${PASSWORD}
    ${resp}=       POST On Session    banking    /cadastro    json=${payload}    expected_status=400
    Salvar JSON Em Arquivo    logs/cadastro_email_existente.json    ${resp.text}

Cadastro Com CPF Existente
    [Documentation]    Testa cadastro de usuário com CPF já existente, esperando erro 400
    Criar Sessao API
    Gerar Massa Usuario
    Cadastrar Usuario
    Confirmar Email
    # Gerar email aleatório para evitar conflito com outro teste
    ${random_int}=    Evaluate    random.randint(1000,9999)    modules=random
    ${novo_email}=    Set Variable    outro_email_${random_int}@example.com
    ${payload}=    Create Dictionary
    ...    cpf=${CPF}
    ...    full_name=Outro Nome
    ...    email=${novo_email}
    ...    password=${PASSWORD}
    ...    confirmPassword=${PASSWORD}
    ${resp}=       POST On Session    banking    /cadastro    json=${payload}    expected_status=400
    Salvar JSON Em Arquivo    logs/cadastro_cpf_existente.json    ${resp.text}

Cadastro Com Senha Fraca
    [Documentation]    Testa cadastro de usuário com senha fraca, esperando erro 400
    Criar Sessao API
    Gerar Massa Usuario
    ${random_int}=    Evaluate    random.randint(1000,9999)    modules=random
    ${novo_email}=    Set Variable    email_fraca_${random_int}@example.com
    ${payload}=    Create Dictionary
    ...    cpf=${CPF}
    ...    full_name=${FULL_NAME}
    ...    email=${novo_email}
    ...    password=12345678
    ...    confirmPassword=12345678
    ${resp}=       POST On Session    banking    /cadastro    json=${payload}    expected_status=400
    Salvar JSON Em Arquivo    logs/cadastro_senha_fraca.json    ${resp.text}