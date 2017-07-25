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
SERVER='192.168.0.100'
FIREHAWK='192.168.0.101'
STEPUP='192.168.0.100'
DESTDIR="/root/wvirt/$SITE"
ORIDIR="/root/wvirt/$SITE"
HASDB="false"
DBORI='192.168.0.101'
DBDEST='192.168.0.100'
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

func_make_quest "Deseja Alterar algum dos parametros? " func_change_param



# -------------------------------------------------------------------
# 2 - Criar estrutura no servidor de destino do site a ser migrado  |
#     - ( script de criação : /root/bin/cria_dominio_bd.sh )        |
# -------------------------------------------------------------------

clear 

echo "Executando script remoto $SERVER:/root/bin/cria_dominio.sh..."

# Realiza remoto na ELITE e executa o script de criação de estrutura
ssh -o ConnectTimeout=5 -l root $SERVER "/root/bin/cria_estrutura.sh $SITE $HASDB $DBNAME $DBUSER $DBPASS"

clear
echo "Acesso remoto encerrado..."
sleep 1 

#-------------------------------------------------------------------------------
# 3 - Sincronizar os arquivos no servidor de origem para o servidor de destino |
#     * Usar rsync -hrazv /home/wvirt/<site>/				       |
#     	* <site>/public_html/ p/ /home/wvirt/<site>/public_html                |
#       * <site>/logs/*      p/ /home/wvirt/<site>/var/log    (log sem 's')    |
#       * <site>/stats/*     p/ /home/wvirt/<site>/var/stats                   |
#       * <site>/data/*      p/ /home/wvirt/<site>/var/data		       |
# ------------------------------------------------------------------------------

# Sincronizando os arquivos na estrutura 

rsync -hrazv /root/wvirt/$SITE/public_html $SERVER:/root/wvirt/$SITE/
rsync -hrazv /root/wvirt/$SITE/logs/*  $SERVER:/root/wvirt/$SITE/var/log/
rsync -hrazv /root/wvirt/$SITE/stats $SERVER:/root/wvirt/$SITE/var/
rsync -hrazv /root/wvirt/$SITE/data  $SERVER:/root/wvirt/$SITE/var/


# ---------------------------------------------------------------------------------
# 4 - Mudar as permissões da pasta public_html para o grupo com o nome do dominio |
#     - ex.: chown -R <site.com.br>:<site.com.br> public_html 		          |
#										  |
# --------------------------------------------------------------------------------|

ssh -o ConnectTimeout=5 -l root $SERVER "chown -R $SITE:$SITE /root/wvirt/$SITE/public_html"





#############################################################################

# 5 - Na pasta /home/wvirt/<site>/var/log/ 
#     - Apagar o arquivo acess_log
#	 * Ex.: rm /home/wvirt/<site>/var/log/access_log
#     - Criar outro link (ln -s) de access_log com o mês atual 
#        * Ex.: no mês de julho: ln -s /home/wvirt/<site>/var/log/access.2017.07.log acces_log
# Restaurando o banco para o mysql no servidor de destino

ssh -l ConnectTimeout=10 -l root $SERVER "rm /root/wvirt/$SITE/var/log/access_log"

ssh -l ConnectTimeout=10 -l root $SERVER "ln -s /root/wvirt/$SITE/var/log/access_log.2017.07.log access_log"



# 6 - Exportar o Banco de dados
#     - Importar  do servidor de origem 
#     - Importar para o servidor de destino
# 

# Acessa o servidor da firehawk e faz dump do banco desejado                      |

echo "Acessando servidor FIREHAWK"
echo "Realizando dump do banco $DBNAME na FIREHAWK"
ssh -o ConnectTimeout=5 -l root $DBORI "mysqldump teste_db > /root/banco/$DBNAME.sql &  rsync -hrazv /root/banco/$DBNAME.sql root@192.168.0.101:/root/banco/$DBNAME.sql"
sleep 1

echo "Enviando $DBNAME.sql para STEPUP..."


ssh -o ConnectTimeout=5 -l root $DBDEST "mysql $DBNAME < /root/banco$DBNAME.sql"

# MSG de encerramento do script
echo "Encerrando o script..."
sleep 1
