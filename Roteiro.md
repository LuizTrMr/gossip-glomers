## Preparação


## Maelstrom
- Jepsen: Uma organização que tem por objetivo melhorar a segurança de sistemas distribuídos
	- Também existe uma biblioteca escrita em Clojure com o mesmo nome
		- Constrói um sistema distribuído e roda várias operações contra esse sistema para o analisar
- Maelstrom: Software construído baseado na biblioteca Jepsen, roda testes de casos específicos que enviam mensagens ao cluster e esperam uma saída específica
	- Roda um arquivo binário como um nó, simula clientes e nós em um cluster

## Desafio 1 - [Echo](https://fly.io/dist-sys/1/)
> Bem simples, clientes mandam uma mensagem a um nó e é necessário responder com a mesma mensagem.

## Desafio 2 - [Unique ID Generation](https://fly.io/dist-sys/2/)
TODO: Tentar ULID? ; Usar só o nome do nó mais o id da mensagem como ID.
> Criar um ID único e universal ao cluster e responder a mensagem com esse ID.

## Desafio 3 - [Broadcast](https://fly.io/dist-sys/3a/)
- a) Single Node
> 

- b) Multi Node
> 
