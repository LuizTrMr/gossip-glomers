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
> Criar um ID único e universal ao cluster e responder a mensagem com esse ID.
	- UUID
	- ULID
	- Usar só o nome do nó mais o id da mensagem como ID.

## Desafio 3 - [Broadcast](https://fly.io/dist-sys/3a/)
- a) Single Node
> Guardar valores recebidos em um array e enviá-los quando um request do tipo `read` for feito para o nó.

- b) Multi Node
### Agora as mensagens são enviadas para um nó, mas todos precisam ser atualizados com a nova mensagem, como em um processo de sincronização entre os nós.
> Primeiro a ideia foi só assim que receber a mensagem de `broadcast`, enviar a mesma mensagem pelo `node_boradcast` pra todos os nós vizinhos segundo a topologia. Mas é preciso atingir TODOS os nós.

> Primeiro, ao receber a mensagem `broadcast`, ela é armazenada e daí, uma mensagem `node_broadcast` é enviada a todos os seus vizinhos. Mas só isso não seria o suficiente, porque nós precisamos repassar a mensagem para TODOS os nós.
Então, além de se armazenar a mensagem ao recebê-la de um `node_broadcast`, nós também a mandamos para todos os vizinhos daquele nó.
Por isso uma modificação foi feita, além de mandar a mensagem recebida, a própria lista de nós vizinhos passa a ser mandada
Mas isso pode ser um pouco redundante, várias mensagens "atoa" seriam trocadas. Dessa forma uma modificação foi feita: além de mandar a mensagem recebida, a própria lista de nós vizinhos também passa a ser mandada, dessa forma, o nó que recebe a mensagem de `node_broadcast` pode agora saber para quais nós a mensagem já foi mandada, assim ele checa a sua própria lista de vizinhos e manda `apenas` para os seus vizinhos que ainda não receberam a mensagem.
Por último, foi feita mais uma alteração, ao invés do nó mandar sua própria lista de vizinhos, ele manda a lista de vizinhos que ele recebeu MAIS os seus vizinhos que não estão incluídos nesta lista, dessa forma existirão menos requisições redundantes.

- c) Fault Tolerant
