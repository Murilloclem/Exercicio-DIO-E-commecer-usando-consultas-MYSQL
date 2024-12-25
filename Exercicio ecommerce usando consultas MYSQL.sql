create database ecommerce;

use ecommerce;

create table cliente(
	idcliente int auto_increment primary key,
	nome varchar(45),
	endereço varchar(200),
	CPF char(11),
	CNPJ char (14),
	check(
		(CPF is not null and CNPJ is null) or (CPF is null and CNPJ is not null)
	)
);


create table fornecedor(
	idfornecedor int auto_increment primary key,
	razaosocial varchar(250),
	CNPJ char(14) not null,
	Contato char (11),
	Estoque_quantidade float,
	endereço varchar(250)
);


create table terceiro_vendedor(
	idvendedor int auto_increment primary key,
	razaosocial varchar (250),
	CNPJ char (14) not null,
	endereço varchar (250),
	contato char (11),
	quantidade_produto float
);


create table produto(
	idproduto int auto_increment primary key,
	pnome varchar (45),	
	categoria enum('eletronico','vestimenta','brinquedo','alimento','móveis'),
	valor numeric (10,2),
	id_fornecedor int,
	id_terceiro_vendedor int,
	constraint FK_fornecedor_produto foreign key (id_fornecedor) references fornecedor (idfornecedor),
	constraint FK_terceiro_vendedor foreign key (id_terceiro_vendedor) references terceiro_vendedor (idvendedor)
);


create table pedido(
	idpedido int auto_increment primary key,
	status enum('aprovado','cancelado','em andamento'),
	descricao varchar(45),
	frete numeric (10,2),
	id_cliente int not null,
	id_produto int not null,
	constraint FK_cliente_pedido foreign key (id_cliente) references cliente (idcliente),
	constraint FK_pruduto_pedido foreign key (id_produto) references produto (idproduto)
);


create table pagamento(
	idpagamento int auto_increment primary key,
	Forma_de_pagamento enum('pix','cartão de debito','cartão de crédito','boleto bancário'),
	id_pedido int not null,
	constraint FK_pedido_pagamento foreign key (id_pedido) references pedido (idpedido)
);



create table confirmacao_compra(
	idconfirmacao int auto_increment primary key,
	confirmacao enum('pagamento realizado','aguardando pagamento','cancelado'),
	id_pagamento int not null,
	constraint FK_pagamento_confirmacao_compra foreign key (id_pagamento) references pagamento (idpagamento)	
);


CREATE TABLE finalizacao_compra (
    idfinalizacao INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('entregue', 'cancelado') NOT NULL,
    id_confirmacao_compra INT NOT NULL,
    id_produto INT NOT NULL,
    valor_reembolso DECIMAL(10, 2),
    resultado_final VARCHAR(255),
    CONSTRAINT FK_finalizacao_compra_produto FOREIGN KEY (id_produto) REFERENCES produto (idproduto),
    CONSTRAINT FK_finalizacao_compra_confirmacao_compra FOREIGN KEY (id_confirmacao_compra) REFERENCES confirmacao_compra (idconfirmacao)
);

ALTER TABLE 
	finalizacao_compra
MODIFY column status ENUM('entregue', 'cancelado','aguardando finalizacao do pedido') NOT NULL;

DELIMITER $$

CREATE TRIGGER trg_finalizacao_compra_calculo
BEFORE INSERT ON finalizacao_compra
FOR EACH ROW
BEGIN
 IF NEW.status = 'cancelado' THEN
        SET NEW.valor_reembolso = (SELECT valor FROM produto WHERE idproduto = NEW.id_produto);
    ELSE
        SET NEW.valor_reembolso = 0;
    END IF;
    
IF NEW.status = 'entregue' THEN
        SET NEW.resultado_final = 'Sucesso';
    ELSEIF NEW.status = 'cancelado' THEN
        SET NEW.resultado_final = CONCAT('Reembolso: R$ ', FORMAT((SELECT valor FROM produto WHERE idproduto = NEW.id_produto), 2));
    ELSE
        SET NEW.resultado_final = 'Indefinido';
    END IF;
END$$

DELIMITER ;




insert into cliente (nome,endereço,CPF) values ('Mario','Parana',18290201810);
insert into cliente (nome,endereço,CNPJ) values ('distribuidora agua viva','Rio De Janeiro',78182818291729);
insert into cliente (nome,endereço,CPF) values ('Maria','São Paulo',18105261728);
insert into cliente (nome,endereço,CNPJ) values ('Mega colchões','Minas Gerais',82910283019201);
insert into cliente (nome,endereço,CNPJ) values ('mercado bom preço','Santa Catarina',92830192019203);
insert into cliente (nome,endereço,CPF) values ('João','Rio Grande do Sul',92910292101);

select * from cliente;

insert into fornecedor (Razaosocial,CNPJ,Contato,Estoque_quantidade,endereço) values ('Super atacado',91028310292021,11998412982,100,'São Paulo');
insert into fornecedor (Razaosocial,CNPJ,Contato,Estoque_quantidade,endereço) values ('Varejista online',19291928192191,41974623711,250,'Parana');
insert into fornecedor (Razaosocial,CNPJ,Contato,Estoque_quantidade,endereço) values ('Elefantinho',83812803021283,21997472124,98,'Rio De Janeiro');

select * from fornecedor;

insert into terceiro_vendedor (razaosocial,CNPJ,endereço,contato,quantidade_produto) values ('Vendas online',10203102010212,'Parana',41998210283,20);
insert into terceiro_vendedor (razaosocial,CNPJ,endereço,contato,quantidade_produto) values ('Ricardo vendas',92821232903212,'São Paulo',11976592127,15);

select * from terceiro_vendedor;


insert into produto (pnome,categoria,valor,idproduto,id_fornecedor) values ('microondas','eletronico',999.99,1,1);
insert into produto (pnome,categoria,valor,idproduto,id_fornecedor) values ('Vestido','vestimenta',99.90,2,3);
insert into produto (pnome,categoria,valor,idproduto,id_fornecedor) values ('Hotwheels','brinquedo',19.99,3,2);
insert into produto (pnome,categoria,valor,idproduto,id_fornecedor) values ('Frango','alimento',15.99,4,3);
insert into produto (pnome,categoria,valor,idproduto,id_fornecedor) values ('Geladeira','eletronico',3999.99,5,2);
insert into produto (pnome,categoria,valor,idproduto,id_terceiro_vendedor) values ('macacao','vestimenta',79.99,6,1);
insert into produto (pnome,categoria,valor,idproduto,id_terceiro_vendedor) values ('Fusca','brinquedo',59.99,7,2);
insert into produto (pnome,categoria,valor,idproduto,id_terceiro_vendedor) values ('Kombi','brinquedo',59.99,8,2);
insert into produto (pnome,categoria,valor,idproduto,id_terceiro_vendedor) values ('Rack','móveis',899.99,9,1);
insert into produto (pnome,categoria,valor,idproduto,id_terceiro_vendedor) values ('Cama','móveis',1499.99,10,1);

select * from produto;


SELECT	
	f.razaosocial, f.CNPJ,
    P.pnome, p.categoria, p.valor
FROM produto p
inner join fornecedor f on p.id_fornecedor = idfornecedor;


SELECT 
    t.razaosocial as Terceiro_razaosocial, 
    t.CNPJ as terceiro_CNPJ, 
    p.pnome as nome_produto, 
    p.categoria as caterogia_produto, 
    p.valor as valor_produto,
    f.razaosocial as fornecedor_razaosocial, 
    f.CNPJ as fornecedor_razaosocial
FROM produto p
left JOIN terceiro_vendedor t ON p.id_terceiro_vendedor = t.idvendedor
left join fornecedor f on p.id_fornecedor = idfornecedor;

insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('aprovado','entregar no apto 45', 60.00,1,1);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('em andamento','Tamanho M',19.99,2,2);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('aprovado',null,00.00,3,3);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('aprovado','Frago assado',20.00,1,4);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('cancelado',null,00.00,4,5);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('aprovado','Tamanho P',19.99,5,6);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('em andamento',null,49.99,6,7);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('cancelado',null,49.99,6,8);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('em andamento','43 polegadas cor preto',89.99,1,9);
insert into pedido (status,descricao,frete,id_cliente,id_produto) values ('aprovado','tamanho casal king',89.99,1,10);
select * from pedido;

SELECT 
    pedido.idpedido,
    pedido.status AS status_pedido,
    pedido.descricao AS descricao_pedido,
    pedido.frete,
    cliente.nome AS nome_cliente,
    produto.pnome AS nome_produto,
    produto.categoria AS categoria_produto,
    produto.valor AS valor_produto,
    fornecedor.razaosocial AS fornecedor_nome,
    terceiro_vendedor.razaosocial AS vendedor_nome
FROM 
    pedido
INNER JOIN 
    cliente ON pedido.id_cliente = cliente.idcliente
INNER JOIN 
    produto ON pedido.id_produto = produto.idproduto
LEFT JOIN 
    fornecedor ON produto.id_fornecedor = fornecedor.idfornecedor
LEFT JOIN 
    terceiro_vendedor ON produto.id_terceiro_vendedor = terceiro_vendedor.idvendedor
    group by nome;
    
insert into pagamento (forma_de_pagamento,id_pedido) values ('pix',1);
insert into pagamento (forma_de_pagamento,id_pedido) values ('cartão de debito',2);
insert into pagamento (forma_de_pagamento,id_pedido) values ('cartão de crédito',3);
insert into pagamento (forma_de_pagamento,id_pedido) values ('boleto bancário',4);
insert into pagamento (forma_de_pagamento,id_pedido) values ('boleto bancário',5);
insert into pagamento (forma_de_pagamento,id_pedido) values ('pix',6);
insert into pagamento (forma_de_pagamento,id_pedido) values ('cartão de crédito',7);
insert into pagamento (forma_de_pagamento,id_pedido) values ('cartão de débito',8);
insert into pagamento (forma_de_pagamento,id_pedido) values ('pix',9);
insert into pagamento (forma_de_pagamento,id_pedido) values ('cartão de debito',10);
select * from pagamento;

insert into confirmacao_compra (confirmacao,id_pagamento) values ('pagamento realizado',1);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('aguardando pagamento',2);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('pagamento realizado',3);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('aguardando pagamento',4);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('cancelado',5);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('pagamento realizado',6);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('pagamento realizado',7);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('cancelado',8);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('pagamento realizado',9);
insert into confirmacao_compra (confirmacao,id_pagamento) values ('pagamento realizado',10);
select * from confirmacao_compra;


insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('entregue',1,1);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('aguardando finalizacao do pedido',2,2);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('aguardando finalizacao do pedido',3,3);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('aguardando finalizacao do pedido',4,4);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('cancelado',5,5);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('entregue',6,6);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('entregue',7,7);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('cancelado',8,8);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('entregue',9,9);
insert into finalizacao_compra (status,id_confirmacao_compra,id_produto) values ('entregue',10,10);

select * from finalizacao_compra;



SELECT
	cliente.nome AS nome_cliente,
	cliente.CPF AS cliente_CPF,
	cliente.CNPJ AS cliente_CNPJ,
	pedido.idpedido,
	pedido.status AS status_pedido,
	pedido.descricao AS descricao_pedido,
	pedido.frete,
	produto.pnome AS nome_produto,
	produto.categoria AS categoria_produto,
	produto.valor AS valor_produto,
	fornecedor.razaosocial AS fornecedor_nome,
	fornecedor.CNPJ AS fornecedor_CNPJ,
	terceiro_vendedor.razaosocial AS terceiro_vendedor_razaosocial,
	terceiro_vendedor.CNPJ AS terceiro_vendedor_CNPJ,
	pagamento.Forma_de_pagamento AS modo_pagamento,
	confirmacao_compra.confirmacao,
	finalizacao_compra.status,
	finalizacao_compra.valor_reembolso AS reembolso
FROM
	cliente
Inner JOIN
	pedido on pedido.id_cliente = cliente.idcliente
INNER JOIN
	produto ON pedido.id_produto = produto.idproduto
LEFT JOIN 
    fornecedor ON produto.id_fornecedor = fornecedor.idfornecedor
LEFT JOIN 
    terceiro_vendedor ON produto.id_terceiro_vendedor = terceiro_vendedor.idvendedor
INNER JOIN 
	pagamento ON pagamento.id_pedido = pedido.idpedido
INNER JOIN
	confirmacao_compra ON confirmacao_compra.id_pagamento = pagamento.idpagamento
INNER JOIN
	finalizacao_compra ON  finalizacao_compra.id_confirmacao_compra = confirmacao_compra.idconfirmacao
    group by nome;
