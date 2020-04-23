#!/bin/bash
### COLOR
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
CNo='\033[0m'
Cred='\033[0;31m'
Cora='\033[0;33m'
Cblue='\033[0;34m'
Cgreen='\033[0;32m'
Cyel='\033[1;33m'
Cpur='\033[0;35m'

declare -A LCOLOR_D
LCOLOR_D[30]='\033[0;31m'
LCOLOR_D[31]='\033[0;31m'
LCOLOR_D[32]='\033[0;32m'
LCOLOR_D[33]='\033[0;33m'
LCOLOR_D[34]='\033[0;34m'
LCOLOR_D[35]='\033[0;35m'
LCOLOR_D[36]='\033[0;36m'
LCOLOR_D[37]='\033[0;37m'
LCOLOR_D[38]='\033[0;35m'
LCOLOR_D[39]='\033[0;37m'
declare -A LCOLOR_L
LCOLOR_L[30]='\033[1;31m'
LCOLOR_L[31]='\033[1;31m'
LCOLOR_L[32]='\033[1;32m'
LCOLOR_L[33]='\033[1;33m'
LCOLOR_L[34]='\033[1;34m'
LCOLOR_L[35]='\033[1;35m'
LCOLOR_L[36]='\033[1;36m'
LCOLOR_L[37]='\033[1;37m'
LCOLOR_L[38]='\033[1;35m'
LCOLOR_L[39]='\033[1;37m'

## LISTA OS BANCOS DE DADOS EXISTENTE
I=0
## CARREGAR LISTA COM OS BANCO DE DADOS
HOST="localhost"
USER="postgres"
PASS="taylon"

read -p "ENTER NAME DATABASE: " READ_DATABASE
read -p "ENTER BY OWNER: " BYOWNER
read -p "ENTER TO OWNER: " TOOWNER

SQL="SELECT COUNT(1) FROM pg_user where usename IN ('${BYOWNER}','${TOOWNER}')"
COUNT_OWNER=$(PGPASSWORD=${PASS} psql -h ${HOST} -U ${USER} -At --command="${SQL}")
# -eq (equal) Igual à
# -ne (not equal) Diferente de
# -lt (less than) Menor que
# -gt (greater than) Maior que
# -le (less or egual) Menor ou igual à
# -ge (greater or equal) Maior ou igual à

if [ $COUNT_OWNER -gt 1 ]; then
	read -p "REALLY WANT TO CONTINUE?[N,y]: " CONFIRM
	if [ "${CONFIRM}" = "Y" ] || [ "${CONFIRM}" = "y" ]; then

		SQL="select datname from pg_database p where p.datname not in ('template1','template0','postgres')  and upper(datname) = upper('${READ_DATABASE}')"
		COUNT_DB=0
		echo -e "${Cblue}DATABASES INFO: ${READ_DATABASE}"
		COMMAN_PSQL=$(PGPASSWORD=${PASS} psql -h ${HOST} -U ${USER} -At --command="${SQL}")
		if [ "$COMMAN_PSQL" = '' ]; then
			echo -e "${Cred}DATABASE NOT EXIST"
			exit
		else
			for DATABASE in ${COMMAN_PSQL}; do #array=("banco1" "banco2" "banco3" "banco4")
				#for DATABASE in "${array[@]}"

				#     psql -h $HOST -d $DATABASE $USER <<-EOQ
				# 	select *
				# from information_schema.schemata p
				# where p.schema_name not in ('pg_toast','pg_temp_1','pg_toast_temp_1','pg_catalog','information_schema') and catalog_name = 'dev_fabiolaserra';
				# 	EOQ
				## LIST ALL SCHEMA
				echo "********************************************************************************************"
				echo "DATABASE: ${DATABASE}"
				SQL_SCHEMA="select schema_name from information_schema.schemata p where p.schema_name not in  ('pg_toast','pg_temp_1','pg_toast_temp_1','pg_catalog','information_schema') and catalog_name = '${DATABASE}' and upper(schema_owner) = upper('${BYOWNER}')"
				COMMAND_SCHEMA=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_SCHEMA}")
				COUNT_SH=0
				COUNT_TB=0
				COUNT_SE=0
				COUNT_VW=0
				COUNT_MV=0
				for SCHEMA in ${COMMAND_SCHEMA}; do
					RAND=$(((RANDOM % 10 + 30)))
					echo -e "${CNo}${LCOLOR_D[${RAND}]}SCHEMA: ${SCHEMA}${CNo}${LCOLOR_L[${RAND}]}"
					## LISTA TABLES
					SQL_TABLE="select schemaname||'.'||tablename from pg_tables where schemaname = '${SCHEMA}' and upper(tableowner) = upper('${BYOWNER}')"
					COMMAND_TABLE=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_TABLE}")
					if [ "$COMMAND_TABLE" != '' ]; then
						for TABLE in ${COMMAND_TABLE}; do
							echo -e "\t TABLE AND OWNER: ${TABLE}"
							# ALTER OWNER
							SQL_T="alter TABLE ${TABLE} owner to ${TOOWNER}"
							EXE_T=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_T}")
							# echo ${TABLE} | sed -e 's/^[a-zA-Z\.\_]\|/''/g' #-e 's/[0-9]/N/g'
							((COUNT_TB++))
						done
					fi

					# LISTA SEQUENCIA
					SQL_SEQUESCE="select sequence_schema||'.'||sequence_name from information_schema.sequences where sequence_schema = '${SCHEMA}'"
					COMMAND_SEQUENCE=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_SEQUESCE}")
					if [ "$COMMAND_SEQUENCE" != '' ]; then
						for SEQUENCE in ${COMMAND_SEQUENCE}; do
							echo -e "\t SEQUENCE: ${SEQUENCE}"
							# ALTER OWNER
							SQL_S="alter SEQUENCE ${SEQUENCE} owner to ${TOOWNER}"
							EXE_S=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_S}")
							((COUNT_SE++))
						done
					fi
					# LISTA VIEWS
					SQL_VIEW="select schemaname||'.'||viewname from pg_catalog.pg_views where schemaname = '${SCHEMA}' and upper(viewowner) = upper('${BYOWNER}')"
					COMMAND_VIEW=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_VIEW}")
					if [ "$COMMAND_VIEW" != '' ]; then
						for VIEW in ${COMMAND_VIEW}; do
							echo -e "\t VIEWS: ${VIEW}"
							# ALTER OWNER
							SQL_V="alter TABLE ${VIEW} owner to ${TOOWNER}"
							EXE_V=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_V}")
							((COUNT_VW++))
						done
					fi
					# LISTA VIEWS
					SQL_VIEW_MAT="select schemaname||'.'||matviewname from pg_matviews where schemaname = '${SCHEMA}' and upper(matviewowner) = upper('${BYOWNER}')"
					COMMAND_VIEW_MAT=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_VIEW_MAT}")
					if [ "$COMMAND_VIEW_MAT" != '' ]; then
						for VIEW_MAT in ${COMMAND_VIEW_MAT}; do
							echo -e "\t MATERIAL VIEWS: ${VIEW_MAT}"
							# ALTER OWNER
							SQL_M="alter TABLE ${VIEW_MAT} owner to ${TOOWNER}"
							EXE_M=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_M}")
							((COUNT_MV++))
						done
					fi
					# ALTER OWNER
					SQL_ALT="ALTER SCHEMA ${SCHEMA} owner to ${TOOWNER}"
					EXE_SC=$(PGPASSWORD=${PASS} psql -h $HOST -d $DATABASE $USER -At --command="${SQL_ALT}")
					((COUNT_SH++))
				done
				((COUNT_DB++))
				LIST[$I]=${DATABASE}
				echo -e "${CNo}${Cyel}########### ${DATABASE} ############"
				#	echo -e "TOTAL DATABASE: ${COUNT_DB}"
				echo -e "TOTAL SCHEMA: ${COUNT_SH}"
				echo -e "TOTAL TABLE: ${COUNT_TB}"
				echo -e "TOTAL SEQUENCE: ${COUNT_SE}"
				echo -e "TOTAL VIEWS: ${COUNT_VW}"
				echo -e "TOTAL MATERIALIZED VIEWS: ${COUNT_MV}"
				echo "##################################"
				((I++))
				echo -e "********************************************************************************************\n"
			done
			echo -e "${CNo}${Cgreen}CONCLUDED"
			exit
		fi
	fi
	echo -e "${CNo}${Cred}OPERATION CANCELED"
else
	echo -e "${CNo}${Cred}OWNER INVALID"
fi
