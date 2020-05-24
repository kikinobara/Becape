#!/bin/bash
TMPFILE=$(mktemp)




while [ "$RESULT" != "5" ]
do

dialog --title "BECAPE - v.0.0.1" --menu "HOME" 15 45 5 \
    1 "Servidores"  \
    2 "Backups"  \
    3 "Histórico de Atividades"  \
    4 "Sobre o Sistema" \
    5 "Sair" 2>$TMPFILE

RESULT=$(cat $TMPFILE)

case $RESULT in

	1)	#SERVIDORES
		TMPFILE1=$(mktemp)

		dialog --title "BECAPE - v.0.0.1" --menu "Backups" 15 45 3 \
	   	1 "Adicionar Servidor"  \
	   	2 "Remover Servidor"  \
	   	3 "Voltar" 2>$TMPFILE1

		RESULT1=$(cat $TMPFILE1)

		case $RESULT1 in

			1)clear # ADICIONAR SERVIDOR

			HOST=$(dialog --inputbox "[Adicionar Servidor] - Digite o Hostname" 15 30 --stdout )  
			IPADDR=$(dialog --inputbox "[Adicionar Servidor] - Digite o Endereço de IP" 15 30 --stdout )  
			DIRORIG=$(dialog --inputbox "[Adicionar Servidor] - Digite o Diretório" 15 30 --stdout )  

			#MONTANDO O HOSTNAME NO DIRETÓRIO  DE MESMO NOME
			echo "montando o hostname no sistema..."
			clear
			cd /home/becape 
			mkdir hosts/$HOST
			sudo mount -t cifs -o username=becape,password=Fatec@2020 //$IPADDR/$DIRORIG/ /home/becape/hosts/$HOST
	 
			echo "Usuário $HOST , IP $IPADDR , diretório $DIRORIG incluído com sucesso em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M)"  | tee -a /home/becape/logs/history.log
			echo "Pressione [ENTER] para continuar..."
			
			read null;;

			 2)clear #REMOVER SERVIDOR
			
			COMPDIR=$(dialog --stdout --title "Selecione um computador para excluir" --fselect /home/becape/hosts/ 14 48)
			
			sudo umount $COMPDIR
			sudo rm -rf $COMPDIR

			echo "removido $COMPDIR do sistema em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M)"  | tee -a /home/becape/logs/history.log
			echo "Pressione [ENTER] para continuar..."
			
			read null;;



 	

	      	3)clear #VOLTAR
			echo "saindo..."
	

			esac;;




    2)clear #BACKUPS
		
		TMPFILE2=$(mktemp)

		dialog --title "BECAPE - v.0.0.1" --menu "Backups" 15 45 6 \
	   	1 "Agendar Backup (Full)"  \
	   	2 "Agendar Backup (Incremental)" \
	   	3 "Listar/Remover Backups agendados"  \
	   	4 "Restaurar Backup" \
	   	5 "Listar Backups Efetuados" \
	   	6 "Voltar" 2>$TMPFILE2

		RESULT2=$(cat $TMPFILE2)

		case $RESULT2 in

			1)clear # AGENDAR BACKUP (FULL)
			
			AGBKP=$(dialog --stdout --title "Selecione um computador para agendar o backup" --fselect /home/becape/hosts/ 14 48)
			HAGBKP=$(basename $AGBKP )
			HORA=$(dialog --inputbox "Hora do início (ex: 09, 20, 23...)" 15 30 --stdout )
			MIN=$(dialog --inputbox "Minutos do início (ex: 30, 45, 59...)" 15 30 --stdout ) 


			touch /home/becape/scripts/$HAGBKP'_full'.sh
			sudo chmod +x /home/becape/scripts/$HAGBKP'_full'.sh
			echo "#!/bin/bash" > /home/becape/scripts/$HAGBKP'_full'.sh
			echo 'tar -czvf /home/becape/bkps/'$HAGBKP'_$(date +%d)_$(date +%b)_$(date +%Y)_$(date +%H):$(date +%M)_full.tar.gz  /home/becape/hosts/'$HAGBKP'' >> /home/becape/scripts/$HAGBKP'_full'.sh
			echo 'echo Backup de '$HAGBKP'_full concluído com sucesso em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M)  | tee -a /home/becape/logs/history.log' >> /home/becape/scripts/$HAGBKP'_full'.sh
			echo 'exit 0' >> /home/becape/scripts/$HAGBKP'_full'.sh

			(crontab -l 2>/dev/null; echo "$MIN $HORA * * * /home/becape/scripts/$HAGBKP'_full'.sh") | crontab -
			


			echo "Agendado Backup Full de $HAGBKP em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M) com sucesso!!! "| tee -a /home/becape/logs/history.log
			echo "Pressione [ENTER] para continuar..."
			
			read null;;
			
			2)clear # AGENDAR BACKUP (INCREMENTAL)
			
			AGBKP1=$(dialog --stdout --title "Selecione um computador para agendar o backup" --fselect /home/becape/hosts/ 14 48)
			HAGBKP1=$(basename $AGBKP1 )
			HORA1=$(dialog --inputbox "Hora do início (ex: 09, 20, 23...)" 15 30 --stdout )
			MIN1=$(dialog --inputbox "Minutos do início (ex: 30, 45, 59...)" 15 30 --stdout ) 


			touch /home/becape/scripts/$HAGBKP1'_incr'.sh
			sudo chmod +x /home/becape/scripts/$HAGBKP1'_incr'.sh
			echo "#!/bin/bash" > /home/becape/scripts/$HAGBKP1'_incr'.sh
			echo 'rsync -vr /home/becape/hosts/'$HAGBKP1' /home/becape/bkps/'$HAGBKP1'_incremental ' >> /home/becape/scripts/$HAGBKP1'_incr'.sh
			echo 'echo Backup de '$HAGBKP1'_incremental concluído com sucesso em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M)  | tee -a /home/becape/logs/history.log ' >> /home/becape/scripts/$HAGBKP1'_incr'.sh
			echo 'exit 0' >> /home/becape/scripts/$HAGBKP1'_incr'.sh

			(crontab -l 2>/dev/null; echo "$MIN1 $HORA1 * * * /home/becape/scripts/$HAGBKP1'_incr'.sh") | crontab -
			


			echo "Agendado Backup Incremental de $HAGBKP1 em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M) com sucesso!!! "  | tee -a /home/becape/logs/history.log
			echo "Pressione [ENTER] para continuar..."
			
			read null;;

			3)clear #LISTAR/REMOVER BACKUP
			
			crontab -e				


			echo "Pressione [ENTER] para continuar..."
			read null;;


			4)clear #RESTAURAR BACKUP
			
				TMPFILE2A=$(mktemp)

				dialog --title "BECAPE - v.0.0.1" --menu "Restaurar Backup" 15 45 3 \
		   		1 "Restaurar Backup (Full)"  \
	   			2 "Restaurar Backup (Incremental)" \
	    		3 "Voltar" 2>$TMPFILE2A

				RESULT2A=$(cat $TMPFILE2A)

				case $RESULT2A in

				1) clear #RESTAURAR BACKUP (FULL)
		
					RESTFULL=$(dialog --stdout --title "Selecione um Backup Full para restaurar" --fselect /home/becape/bkps/ 25 120 )
					HOSTFULL=$(dialog --stdout --title "Selecione o computador " --fselect /home/becape/hosts/ 25 120 ) 


					sudo mkdir $HOSTFULL/restore_full_$(date +%a)_$(date +%d)_$(date +%b)_$(date +%Y)_$(date +%H):$(date +%M)


					sudo tar -xzvf $RESTFULL -C $HOSTFULL/restore_full_$(date +%a)_$(date +%d)_$(date +%b)_$(date +%Y)_$(date +%H):$(date +%M)

			

					echo "Backup $RESTFULL efettuado em $HOSTFULL em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M)"  | tee -a /home/becape/logs/history.log
					echo "Pressione [ENTER] para continuar..."
			
					read null;;

		
			


				2) clear #RESTAURAR BACKUP (INCREMENTAL)
											

						RESTFULL=$(dialog --stdout --title "Selecione um Backup Incremental para restaurar" --fselect /home/becape/bkps/ 25 120 )
						HOSTFULL=$(dialog --stdout --title "Selecione o computador " --fselect /home/becape/hosts/ 25 120 ) 


						sudo mkdir $HOSTFULL/restore_$(date +%a)_$(date +%d)_$(date +%b)_$(date +%Y)_$(date +%H):$(date +%M)


						sudo cp -rv $RESTFULL $HOSTFULL/restore_incr_$(date +%a)_$(date +%d)_$(date +%b)_$(date +%Y)_$(date +%H):$(date +%M)

			

						echo "Backup $RESTFULL efettuado em $HOSTFULL em $(date +%a), $(date +%d) $(date +%b) $(date +%Y) $(date +%H):$(date +%M)"  | tee -a /home/becape/logs/history.log
						echo "Pressione [ENTER] para continuar..."
			

						read null;;

					


				3) clear #VOLTAR
			
					esac;; 


			
			5) 	clear #LISTAR BACKUPS EFETUADOS

				dialog --stdout --title "Backups Efetuados: " --fselect /home/becape/bkps/ 25 120 ;;



			6) clear #VOLTAR
			
					esac;; 

     


     3)clear #HISTORICO DE ATIVIDADES
			
		dialog --title 'Histórico de Atividades' --textbox /home/becape/logs/history.log 0 0 ;;
			


    


    4) clear #DISCLAIMER
		dialog --title 'Sobre o Sistema' --textbox /home/becape/system/disclaimer.txt 0 0 ;;

 	

    

    5)clear #SAIR DO SISTEMA
		echo "saindo..."
	

esac

done 




exit 0
