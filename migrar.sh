#!/bin/bash
#######################################
# Autor: Mauro Vieira		      #
# Sistema: Realiza migração de sites  #
#######################################

clear
# Variaveis padrão
USER='root'
SERVER='192.168.0.100'
DESTDIR='/home/wvirt'
HASDB="false"
DBNAME=''
DBUSER=''
DBPASS=''
RESPDB=''
SITE=''

#*******************************************************
#						       *
# Funções do sistema				       *
#						       *
#*******************************************************


# Exibe o valor atual dos parâmetros na tela

show_param () {
	echo "função funcionando"
	
	# Testa se há banco de dados
	if test "$HASDB" = "true"
	then		
	# Exibe parametros do banco de dados ( NOME DO BANCO, USUARIO DO BANCO E SENHA DO BANCO )
		echo "Esses são os parâmetros atuais:"
		echo "1 - Servidor de destino  : $SERVER"
		echo "2 - Diretorio de destino : $DESTDIR"
		echo "3 - Site atual           : $SITE"
		echo "4 - Nome do banco        : $BDNAME"
		echo "5 - Usuário do banco     : $DBUSER"
		echo "6 - Senha do banco       : $DBPASS"
	else
	# Exibe os parâmetros sem as informações relativas a banco de dados
	
		echo "Esses são os parâmetros atuais:"
		echo "1 - Servidor de destino  : $SERVER"
		echo "2 - Diretorio de destino : $DESTDIR"
		echo "3 - Site atual           : $SITE"
	fi
}

# Altera os parâmetros

change_param () {

	# Loop controlado por sentinela enquanto a resposta for s (sim)	
	while test "$RESP" = "s"
	do
		clear
		echo "Digite o número do parametro que deseja alterar"

		echo "Esses são os parâmetros atuais:"
		echo "1 - Servidor de destino  : $SERVER"
		echo "2 - Diretorio de destino : $DESTDIR"
		echo "3 - Site atual           : $SITE"
		echo "4 - Nome do banco        : $BDNAME"
		echo "5 - Usuário do banco     : $DBUSER"
		echo "6 - Senha do banco       : $DBPASS"
		echo ""
		read PARAM
	
		# Testa o parâmetro que deseja alterar
		case $PARAM in

			1) echo "Insira o servidor de destino:"
			read SERVER;;
			2) echo "Insira o diretorio de destino:"
			read DESTDIR;;
			3) echo "Insira o site que deseja migrar:"
			read SITE;;
			4) echo "Insira o nome do banco:"
			read BDNAME;;
			5) echo "Insira o nome do usuário do banco:"
			read USERDB;;
			6) echo "Insira a senha do banco:"
			read PASSDB;;
			*) echo "Opção invalida"
			sleep 2;;
		esac
		
		clear
		show_param		
		echo ""
		sleep 1
		# Pergunta se deseja alterar
		echo "Deseja alterar mais algum parâmetro? [s/n]"
		echo ""
		read RESP
	done
}


# ========================================================================================================
# ========================================================================================================
# ========================================================================================================

# Inicio do programa


echo "Qual o site que deseja migrar?"
read SITE

echo "Possui banco de dados? [s/n]"
read RESPDB


# Caso possua banco $HASDB recebe true
if test "$RESPDB" != "n" 
	then
		HASDB="true"
		echo "Digite o nome do banco:"
		read DBNAME
		echo "Digite o nome do usuário do banco:"
		read DBUSER
		echo "Digite a senha do banco"
		read DBPASS
	else
		HASDB="false"
fi

clear

# Chama função de mostrar os valores atuais dos parametros
show_param

echo ""
sleep 1

echo "Deseja alterar algum dos parametros? [s/n]"
read RESP
	# Caso sim, inicia a função de alterar parâmetros
	test "$RESP" = "s" && change_param
clear 
echo "Realizando acesso remoto..."
sleep 2

# Realiza o acesso remoto
ssh root@$SERVER

clear
echo "Acesso remoto encerrado..."
sleep 2

# MSG de encerramento do script
echo "Encerrando o script..."
sleep 2

	
