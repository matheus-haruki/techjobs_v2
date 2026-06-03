# Telas Candidato:
    A vaga para o candidato deve ter um status: [unseen, dislike, like, match]

    - Feed de Vagas:
        - Traz as vagas existentes (unseen que serão exibidas somente uma vez): Ao dar like na vaga mudar status para like; Ao dar dislike mudar para dislike, quando a empresa deu like no candidato e o candidato da like na vaga mudar para match!
        - Card da Vaga: 
            - Nome da Vaga
            - Empresa
            - Modelo e Localização
            - Tecnologias: (Similar a Skills do Candidato)
            - Descrição da vaga
            - Btn Ver Detalhes (navega ao Detalhes da Vaga)

        
    - Detalhes da vaga: 
        - Título da vaga
        - Nome empresa
        - Modelo e Localizaçaõ (caso remoto, sem localização)
        - Faixa Salarial: (4.000 - 5.000)
        - Tecnologias: (Similar a Skills do Candidato)
        - Descrição da vaga
    - Buscar vagas: 
        - Traz as vagas existentes (possível ver mais de uma vez)
        Existe um campo de Busca de Vagas
        Pequeno filtro onde filtramos modelo de trabalho: (Presencial, Remoto, Híbrido)
        - Card da Vaga: 
            - Nome da Vaga
            - Empresa
            - Modelo e Localização (caso remoto, sem localização)
            - Tag Inscrito (Caso inscrito na vaga)
    
    - Minhas Conexões:
        - Mostra vagas que houveram conexão (Like Mútuo);
        - Card da Vaga:
            - Nome da Vaga
            - Nome da Empresa
            - Btn Ver Vaga (navega ao Detalhes da Vaga)
            - Btn Mensagem (navega ao Chat)

---

# Telas Empresa:
     - Feed de Candidatos, deve existir um btn onde posso alternar entre as minhas vagas cadastradas, visto que a empresa pode criar mais de uma vaga... Mostra o feed de candidatos existentes na rede toda, para cada vaga selecionada todos os candidatos devem ser exibidos somente uma vez  (unseen, like, dislike, match), funciona de maneira similar às vagas para o candidato, porém sendo possível alternar entre as vagas.
        - Card de Inscrito:
            - Avatar
            - Nome 
            - Cargo
            - Skills
            - "Sobre mim"
            - Btn Ver Perfil (navega a tela Perfil do Candidato)
    
    - Perfil do Candidato:
        - Avatar
        - Nome 
        - Cargo
        - Skills
        - "Sobre mim"

    - Minhas Vagas:
        - Btn de criar vagas (navega à tela "Nova Vaga") na AppBar
        - Card das minhas vagas
        - Card da vaga:
            - Nome da vaga
            - Modelo e Localização (caso remoto, sem localização)
            - Quantidade de Matches
            - Btn Gerenciar (navega á tela Gerenciar Vaga)
    
    - Nova Vaga: 
        - Input Titulo da vaga
        - Modelo (Caso presencial ou híbrido um campo de localização deve ser exibido)
        - Faixa Salarial
        - Skills desejadas
        - Descricao
        - Btn "Publicar Vaga" 
    
    - Gerenciar Vaga:
        - Nome da vaga
        - Modelo e Localização
        - Adicionar Descricao da vaga que no momento nao existe 
        - Quantidade de matches
        - Perfil dos Candidatos Match (possível navegar ao Perfil do Candidato)
        - Btn Excluir Vaga
    
    
    



