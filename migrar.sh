#!/bin/bash
#######################################
# Autor: Mauro Vieira                 #
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
#       * <site>/public_html/ p/ /home/wvirt/<site>/public_html
#       * <site>/logs/*      p/ /home/wvirt/<site>/var/log    (log sem 's')
#       * <site>/stats/*     p/ /home/wvirt/<site>/var/stats
#       * <site>/data/*      p/ /home/wvirt/<site>/var/data
#
# 4 - Mudar as permissões da pasta public_html para o grupo com o nome do dominio
#     - ex.: chown -R <site.com.br>:<site.com.br> public_html
#
# 5 - Na pasta /home/wvirt/<site>/var/log/
#     - Apagar o arquivo acess_log
#        * Ex.: rm /home/wvirt/<site>/var/log/access_log
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

FIREHAWK='200.229.2.121' # Banco firehawk
STEPUP='200.229.1.33' # Banco stepup
ELITE='200.229.1.139' # www da ELITE ( Servidor destino )

USER='root'
SERVER="$ELITE"
DESTDIR="/home/wvirt/$SITE"
ORIDIR="/home/wvirt/$SITE"
HASDB="false"
DBORI="$FIREHAWK"
DBDEST="$STEPUP"
DBNAME=''
DBUSER=''
DBPASS=''
RESPDB=''
SITE=''
ESTRUTURA=''

#*******************************************************
#                                                      *
#              FUNCOES DO SCRIPT                       *
#                                                      *
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
#               func_make_quest               |
#                                             |
# Cria um loop com uma pergunta desejada e    |
# Recebe três parametros onde:                |
# 1º - pergunta desejada                      |
# 2º - Ação a ser executada caso seja S       |
# 3º - Ação a ser executada caso seja N       |
# Cria uma pergunta que recebe 's' ou 'n'[s/n]|
#                                             |
#---------------------------------------------|
# EH invocada nas funções |                   |
# --------------------------------------------|
# Invoca as funções      |                    |
# ---------------------------------------------
# ex.: func_make_quest "Deseja execultar ifconfig?" ifconfig exit


func_make_quest (){
        local QUEST=$1
        local RESP

        echo "$QUEST[s/n]"
        read RESP

        case "$RESP" in
                "S")
                     $2;;
                "s")
                     $2;;
                "n")
                     $3;;
                "N")
                     $4;;
                *) echo "Opção inválida"
                   func_make_quest "$1" $2 $3;;
        esac
}


#func_make_quest "Gostaria de realizar um teste??" ifconfig


#----------------------------------------------
#              func_show_param                |
#                                             |
#  Exibe o valor atual dos parâmetros na tela |
#---------------------------------------------|
# EH invocada nas funções | func_change_par |
# --------------------------------------------|
# Invoca as funções      |                    |
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
                echo "4 - Tamanho da estrutura : $ESTRUTURA"
                echo "5 - Nome do banco        : $DBNAME"
                echo "6 - Usuário do banco     : $DBUSER"
                echo "7 - Senha do banco       : $DBPASS"
        else
        # Exibe os parâmetros sem as informações relativas a banco de dados

                echo "Esses são os parâmetros atuais:"
                echo "1 - Servidor de destino  : $SERVER"
                echo "2 - Diretorio de destino : $DESTDIR"
                echo "3 - Site atual           : $SITE"
                echo "4 - Tamanho da estrutura : $ESTRUTURA"
        fi
}



#----------------------------------------------
#               func_change_param             |
#                                             |
#  Altera os valores atuais dos parametros    |
#---------------------------------------------|
# EH invocada nas funções:| Invoca as fcoes |
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
                                4) echo "Insira o tamanho da estrutura. Ex.: 5GB ou 5MB:"
                                read ESTRUTURA;;
                                5) echo "Insira o nome do banco:"
                                read DBNAME;;
                                6) echo "Insira o nome do usuário do banco:"
                                read DBUSER;;
                                7) echo "Insira a senha do banco:"
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
                                4) echo "Insira o tamanho da estrutura. Ex.: 5GB ou 5MB:"
                                read ESTRUTURA;;
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

# 1 - Receber dados necessários para acessos e alterações
#     - nome do site;
#     - servidor de destino;
#     - pasta destino,
#     - tamanho da estrutura;
#     - nome do banco;
#     - usuario do banco;
#     - senha do banco.


echo "Qual o site que deseja migrar?"
read SITE

echo "Insira o tamanho da estrutura. Ex.: 5GB ou 5MB:"
read ESTRUTURA

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

#clear

echo "#############################################################"
echo "Executando script remoto $SERVER:/root/bin/cria_dominio.sh..."

#Realiza remoto na ELITE e executa o script de criação de estrutura
#ssh -o ConnectTimeout=10 -l root $SERVER "/root/bin/cria_dominio.sh $SITE $HASDB $DBNAME $DBUSER $DBPASS"
ssh -l root $SERVER "/root/bin/cria_dominio_bd.sh"

echo "#############################################################"
#clear
#echo "Acesso remoto encerrado..."
#sleep 1

#-------------------------------------------------------------------------------
# 3 - Sincronizar os arquivos no servidor de origem para o servidor de destino |
#     * Usar rsync -hrazv /home/wvirt/<site>/                                  |
#       * <site>/public_html/ p/ /home/wvirt/<site>/public_html                |
#       * <site>/logs/*      p/ /home/wvirt/<site>/var/log    (log sem 's')    |
#       * <site>/stats/*     p/ /home/wvirt/<site>/var/stats                   |
#       * <site>/data/*      p/ /home/wvirt/<site>/var/data                    |
# ------------------------------------------------------------------------------

# Sincronizando os arquivos na estrutura

echo "#############################################################"
echo "Sincronizando os arquivos da estrutura..."
echo " "

rsync -hrazv /home/wvirt/$SITE/public_html $SERVER:/home/wvirt/$SITE/
rsync -hrazv /home/wvirt/$SITE/logs/*  $SERVER:/home/wvirt/$SITE/var/log/
rsync -hrazv /home/wvirt/$SITE/stats $SERVER:/home/wvirt/$SITE/var/
rsync -hrazv /home/wvirt/$SITE/data  $SERVER:/home/wvirt/$SITE/var/


echo "#############################################################"
echo " "
# ---------------------------------------------------------------------------------
# 4 - Mudar as permissões da pasta public_html para o grupo com o nome do dominio |
#     - ex.: chown -R <site.com.br>:<site.com.br> public_html                     |
#                                                                                 |
# ---------------------------------------------------------------------------------
echo " "
echo "#############################################################"
echo " "
echo " Alterando as permissões da pasta public_html para o grupo $SITE "

ssh -l root $SERVER "chown -R $SITE:$SITE /home/wvirt/$SITE/public_html"

echo " "
echo "#############################################################"
echo " "




# -----------------------------------------------------------------------------------------------
# 5 - Na pasta /home/wvirt/<site>/var/log/                                                      |
#     - Apagar o arquivo acess_log                                                              |
#        * Ex.: rm /home/wvirt/<site>/var/log/access_log                                        |
#     - Criar outro link (ln -s) de access_log com o mês atual                          |
#        * Ex.: no mês de julho: ln -s /home/wvirt/<site>/var/log/access.2017.07.log acces_log  |
# Restaurando o banco para o mysql no servidor de destino                                       |
#                                                                                               |
# -----------------------------------------------------------------------------------------------

echo " "
echo "#############################################################"
echo " "

echo "Apagando arquivo access_log..."
ssh -l  root $SERVER "rm /home/wvirt/$SITE/var/log/access_log"

echo " Criando link do access_log com o log do mes atual "
ssh -l  root $SERVER "ln -s /home/wvirt/$SITE/var/log/access.2017.08.log /home/wvirt/$SITE/var/log/access_log"


echo " "
echo "#############################################################"
echo " "

# ----------------------------------------------------------------------
# 6 - Exportar o Banco de dados [ executando script remoto migrar_2.sh ]|
#     - Importar  do servidor de origem                                 |
#     - Importar para o servidor de destino                             |
#                                                                       |
# ----------------------------------------------------------------------

# Acessa o servidor da firehawk e faz dump do banco desejado
# Executa o script remoto em /root/bin/migrar_2.sh

echo "Realizando dump do banco $DBNAME & enviando o dump para FIREHAWK..."

CMDDUMP="/root/bin/migrar_2.sh $DBDEST $DBNAME"

ssh -l root $DBORI "$CMDDUMP"

# Conteudo do script remoto migrar_2.sh

# ====================================================================================================================
# $DBNAME=$1 ** $DBDEST=$2
# $DBDEST = STEPUP
# DBDEST=$1
# DBNAME=$2
#
# mysqldump $DBNAME > /home/dump-panther/$DBNAME.sql
#
# rsync -hrazv /home/dump-panther/$DBNAME.sql root@$DBDEST:/home/Bancos-Panther/$DBNAME.sql
#
# ssh -l root $DBDEST "mysql $DBNAME < /home/Bancos-Panther/$DBNAME.sql"
# sleep 1
#
# echo "-------------------------------------"
# echo " "
# echo "Enviando $DBNAME.sql para STEPUP..."
# echo " "
#
# ssh -l root $DBORI "mysql $DBNAME < /home/Bancos-Panther/$DBNAME.sql"
#
# ====================================================================================================================

echo " "
echo "#############################################################"
echo " "
echo " Encerrando o script..."
