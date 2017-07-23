#!/bin/bash
#######################################
# Autor: Mauro Vieira		      #
# Sistema: Realiza migração de sites  #
#######################################

# Dividido de acordo com o seguinte checklist
# 1 - Receber dados necessários para acessos e alterações
#     - nome do site;
#     - servidor de destino; 
#     - pasta destino, 
#     - tamanho da estrutura; 
#     - nome do banco; 
#     - usuario do banco;
#     - senha do banco.
#
# 2 - Criar estrutura no servidor de destino do site a ser migrado  
#     - ( script de criação : /root/bin/cria_dominio_bd.sh )
#   
# 3 - Sincronizar os arquivos no servidor de origem para o servidor de destino 
#     * Usar rsync -hrazv /home/wvirt/<site>/
#     	* <site>/public_html/ p/ /home/wvirt/<site>/public_html
#       * <site>/logs/*      p/ /home/wvirt/<site>/var/log    (log sem 's')
#       * <site>/stats/*     p/ /home/wvirt/<site>/var/stats 
#       * <site>/data/*      p/ /home/wvirt/<site>/var/data
#
# 4 - Mudar as permissões da pasta public_html para o grupo com o nome do dominio 
#     - ex.: chown -R <site.com.br>:<site.com.br> public_html 
#
# 5 - Na pasta /home/wvirt/<site>/var/log/ 
#     - Apagar o arquivo acess_log
#	 * Ex.: rm /home/wvirt/<site>/var/log/access_log
#     - Criar outro link (ln -s) de acess_log com o mês atual 
#        * Ex.: no mês de julho: ln -s /home/wvirt/<site>/var/log/access.2017.07.log acces_log
# 
# 6 - Exportar o Banco de dados
#     - Importar  do servidor de origem 
#     - Importar para o servidor de destino
# 
#


clear
# Variaveis padrão - Globais
USER='root'
SERVER='192.168.25.100'
DESTDIR='/home/wvirt'
ORIDIR='/home/wvirt'
HASDB="false"
DBNAME=''
DBUSER=''
DBPASS=''
RESPDB=''
SITE=''

#*******************************************************
#						       *
#              FUNÇÕES DO SCRIPT		       *
#						       *
#*******************************************************

func_set_db () {
		HASDB="true"
		echo "Digite o nome do banco:"
		read DBNAME
		echo "Digite o nome do usuário do banco:"
		read DBUSER
		echo "Digite a senha do banco"
		read DBPASS

}




#----------------------------------------------
#  		func_make_quest               |
#                                             |
# Cria um loop com uma pergunta desejada e    |		      
# Recebe três parametros onde:                |
# 1º - pergunta desejada                      |
# 2º - Ação a ser executada caso seja S       |
# 3º - Ação a ser executada caso seja N       |
# Cria uma pergunta que recebe 's' ou 'n'[s/n]|
#  					      |
#---------------------------------------------|
# É invocada nas funções | 		      |
# --------------------------------------------|
# Invoca as funções      |	              |
# ---------------------------------------------
# ex.: func_make_quest "Deseja execultar ifconfig?" ifconfig exit


func_make_quest (){
	local QUEST=$1
	local RESP
	
	echo "$QUEST[s/n]"
	read RESP
	
	case "$RESP" in
		"S") echo "S"
		     $2;;
		"s") echo "s"
		     $2;;
		"n") echo "n"
		     $3;;
		"N") echo "N"
		     $4;;
		*) echo "Opção inválida"
		   func_make_quest "$1" $2 $3;;
	esac
}


#func_make_quest "Gostaria de realizar um teste??" ifconfig


#----------------------------------------------
# 	       func_show_param                |
#					      |
#  Exibe o valor atual dos parâmetros na tela |
#---------------------------------------------|
# É invocada nas funções | func_change_param  |
# --------------------------------------------|
# Invoca as funções      |	              |
# ---------------------------------------------
func_show_param () {
	echo "função funcionando"
	
	# Testa se há banco de dados
	if test "$HASDB" = "true"
	then		
	# Exibe parametros do banco de dados ( NOME DO BANCO, USUARIO DO BANCO E SENHA DO BANCO )
		echo "Esses são os parâmetros atuais:"
		echo "1 - Servidor de destino  : $SERVER"
		echo "2 - Diretorio de destino : $DESTDIR"
		echo "3 - Site atual           : $SITE"
		echo "4 - Nome do banco        : $DBNAME"
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



#----------------------------------------------
# 		func_change_param	      |
#					      |
#  Altera os valores atuais dos parametros    |
#---------------------------------------------|
# É invocada nas funções:| Invoca as funções  |
# --------------------------------------------|
#                        | func_show_param    |
#                        | func_make_quest    |
# ---------------------------------------------


func_change_param () {
	local PARAM
	clear
	func_show_param
	
	echo "Digite o número do parametro que deseja alterar:"
	read PARAM
	
	# testa se tem banco de dados
	if [ $HASDB = "true" ]
		then
			# Caso tenha banco, fará teste com parametros de banco
			case $PARAM in

				1) echo "Insira o servidor de destino:"
				read SERVER;;
				2) echo "Insira o diretorio de destino:"
				read DESTDIR;;
				3) echo "Insira o site que deseja migrar:"
				read SITE;;
				4) echo "Insira o nome do banco:"
				read DBNAME;;
				5) echo "Insira o nome do usuário do banco:"
				read DBUSER;;
				6) echo "Insira a senha do banco:"
				read DBPASS;;
				*) echo "Opção inválida"
				   func_change_param;;
			esac
		else
			# Caso não tenha banco, fará teste sem os parametrôs do banco
			case $PARAM in

				1) echo "Insira o servidor de destino:"
				read SERVER;;
				2) echo "Insira o diretorio de destino:"
				read DESTDIR;;
				3) echo "Insira o site que deseja migrar:"
				read SITE;;
				*) echo "Opção inválida"
				   func_change_param;;
			esac
	fi
	clear
	func_show_param	
	func_make_quest "Deseja alterar mais algum parametro? " func_change_param
	
}


#func_change_param () {
#	clear
#	local RESP
	# Loop controlado por sentinela enquanto a resposta for s (sim)	
#	while test "$RESP" = "s"
#	do
#
#		# Chama função para exibir valor dos parametros atuais
#		func_show_param
#		echo ""
#
#		echo "Digite o número do parametro que deseja alterar"
#		read PARAM
#		clear
#			
#		# Testa o parâmetro que deseja alterar
#		case $PARAM in
#
#			1) echo "Insira o servidor de destino:"
#			read SERVER;;
#			2) echo "Insira o diretorio de destino:"
#			read DESTDIR;;
#			3) echo "Insira o site que deseja migrar:"
#			read SITE;;
#			4) echo "Insira o nome do banco:"
#			read DBNAME;;
#			5) echo "Insira o nome do usuário do banco:"
#			read DBUSER;;
#			6) echo "Insira a senha do banco:"
#			read DBPASS;;
#			*) echo "Opção inválida"
#				func_change_param
#			sleep 2;;
#		esac
#		
#		clear
#		func_show_param		
#		echo ""
#		sleep 1
#		# Pergunta se deseja alterar
#		func_make_quest "Deseja alterar mais algum parâmetro? [s/n]" func_change_param
#		clear
#	done
#}


# ========================================================================================================
# ========================================================================================================
# ========================================================================================================

# Inicio do programa

echo "Qual o site que deseja migrar?"
read SITE

func_make_quest "Possui banco de dados?" func_set_db

# Chama função de mostrar os valores atuais dos parametros
clear
func_show_param

echo ""
sleep 1

func_make_quest "Deseja Alterar algum dos parametros? " func_change_param

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

	
