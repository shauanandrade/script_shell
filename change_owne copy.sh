#!/bin/sh

set pass "taylon\r"
## LISTA OS BANCOS DE DADOS EXISTENTE
I=0
## CARREGAR LISTA COM OS BANCO DE DADOS
HOST="localhost"
USER="postgres"
SQL="select datname from pg_database p where p.datname not in ('template1','template0','postgres')"
COMMAN_PSQL=$(psql -h ${HOST} -U ${USER} -W -At --command="${SQL}")
echo "ENTER PASSWORD OF USER [${USER}] TO LIST DATABASE:"
wait
for DATABASE in ${COMMAN_PSQL}
#array=("banco1" "banco2" "banco3" "banco4")
#for DATABASE in "${array[@]}"
do
	echo "[ $I ] - ${DATABASE}"
	LIST[$I]=${DATABASE}
	((I++))
done