CREATE DATABASE mecanica;
USE mecanica;

CREATE TABLE Pessoa (
    idPessoa INT AUTO_INCREMENT PRIMARY KEY,
    Pnome VARCHAR(13) NOT NULL,
    Sobrenome VARCHAR(13) NOT NULL,
    CPF CHAR(11),
    Endereco VARCHAR(45),
    Contato CHAR(11) NOT NULL,
    CONSTRAINT CPF_unique UNIQUE (CPF)
);

CREATE TABLE Cliente (
    idCliente INT PRIMARY KEY,
    Pessoa_idPessoa INT NOT NULL,
    CONSTRAINT fk_pessoa_cliente FOREIGN KEY (Pessoa_idPessoa) REFERENCES Pessoa(idPessoa) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Veiculo ( 
    idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
    Modelo VARCHAR(45) NOT NULL,
    Placa CHAR(7) NOT NULL,
    Cliente_idCliente INT NOT NULL,
    CONSTRAINT Placa_unique UNIQUE (Placa),
    CONSTRAINT fk_cliente_veiculo FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE Avaliacao ( 
    idAvaliacao INT AUTO_INCREMENT PRIMARY KEY,
    Tipo ENUM('Preventiva','Manutencao') NOT NULL 
);

CREATE TABLE Grupo_mecanico (
    idGrupo_mecanico INT PRIMARY KEY,
    Avaliacao_idAvaliacao INT NOT NULL,
    CONSTRAINT fk_avaliacao_grupo FOREIGN KEY (Avaliacao_idAvaliacao) REFERENCES Avaliacao(idAvaliacao)
);


CREATE TABLE Mecanico (
    idMecanico INT PRIMARY KEY,
    Pessoa_idPessoa INT NOT NULL,
    idGrupoMecanico INT NOT NULL,
    CONSTRAINT fk_grupo_mecanico FOREIGN KEY (idGrupoMecanico) REFERENCES Grupo_mecanico(idGrupo_mecanico), 
    CONSTRAINT fk_pessoa_mecanico FOREIGN KEY (Pessoa_idPessoa) REFERENCES Pessoa(idPessoa) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE OS (
    idOS INT PRIMARY KEY,
    Data_de_emissao DATE NOT NULL, 
    StatusOS ENUM('Concluida','Rejeitada','Em servico','Em aprovacao'), 
    Data_Conclusao DATE, 
    Grupo_mecanico_idGrupo_mecanico INT NOT NULL,
    Valor_Total FLOAT NOT NULL,
    Avaliacao_idAvaliacao INT NOT NULL,
    CONSTRAINT Dt_conclusao CHECK (Data_Conclusao > Data_de_emissao),
    FOREIGN KEY (Grupo_mecanico_idGrupo_mecanico) REFERENCES Grupo_mecanico(idGrupo_mecanico) ON UPDATE CASCADE,
    FOREIGN KEY (Avaliacao_idAvaliacao) REFERENCES Avaliacao(idAvaliacao)
);

CREATE TABLE Servico ( 
    idServico INT AUTO_INCREMENT PRIMARY KEY,
    Descricao VARCHAR(200), 
    idAutorizaçãoOs INT NOT NULL,
    CONSTRAINT fk_servico_autorizado FOREIGN KEY (idAutorizaçãoOs ) REFERENCES OS(idOS)
);

CREATE TABLE Autorizacao_do_cliente ( 
    idAutorizacao_do_cliente INT PRIMARY KEY,
    DataAutorizacao DATE, 
    Status_autorizacao ENUM('Aprovado','Rejeitado','Em analise') DEFAULT 'Em analise', 
    OS_idOS INT,
    OS_Avaliacao INT,
    CONSTRAINT fk_os_autorizacao FOREIGN KEY (OS_idOS) REFERENCES OS(idOS),
    CONSTRAINT fk_avaliacao FOREIGN KEY (OS_Avaliacao) REFERENCES Avaliacao(idAvaliacao) ON UPDATE CASCADE
);

CREATE TABLE Peca (
    idPeca INT PRIMARY KEY,
    Valor FLOAT,
    Nome VARCHAR(45)
);

CREATE TABLE peca_servico (
    idPeca INT,
    idServico INT,
    Quantidade INT,
    PRIMARY KEY (idPeca, idServico),
    CONSTRAINT fk_peca_servico FOREIGN KEY (idPeca) REFERENCES Peca(idPeca),
    CONSTRAINT fk_servico_peca FOREIGN KEY (idServico) REFERENCES Servico(idServico)
);

SELECT concat(p.Pnome,' ' ,p.Sobrenome) as nome, v.Modelo, v.Placa 
FROM Pessoa p 
	JOIN Cliente c ON p.idPessoa = c.Pessoa_idPessoa 
	JOIN Veiculo v ON c.idCliente = v.Cliente_idCliente
    ORDER BY nome;

SELECT s.Descricao, a.Tipo 
FROM Servico s 
	INNER JOIN OS o ON s.idAutorizaçãoOs = o.idOS 
	INNER JOIN Avaliacao a ON o.Avaliacao_idAvaliacao = a.idAvaliacao
		WHERE a.Tipo = 'Preventiva';
        
SELECT AVG(Valor_Total) as MediaValor, MONTH(Data_Conclusao) as Mes
	FROM OS 
		GROUP BY MONTH(Data_Conclusao);
		
SELECT * FROM Pessoa, Mecanico
	WHERE idPessoa = idMecanico;