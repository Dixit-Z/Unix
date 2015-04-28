#!/bin/bash

###############################################################################################################################################################################
#~ 													Calculatrice à 4 étages - TRINTA Bruno - IATIC3 - Projet UNIX
###############################################################################################################################################################################

X=0 Y=0 Z=0 T=0 #Définition des différents étages.
undo_TY=0 undo_X=0

echo "Tous les paliers sont initialisés à 0."
echo -e "Appuyez sur u pour défaire une action.\nEntrez man pour afficher le manuel.\nAppuyez sur q quand vous aurez terminé vos calculs.\n\nVous pouvez entrez les valeurs:"
#Explications du programme à l'utilisateur

while [ 1 ]		#Boucle infini permettant l'utilisation en continu de la calculatrice, jusqu'à ce que l'utilisateur appuie sur 'q'
do
	read typing #On lit ce que l'utilisateur va taper

	if echo $typing | egrep -q '^-*[0-9]+$'		#Si c'est un chiffre alors on mets le chiffre tapé dans le premier étage et on décale
	then
		last="nop"
		undo_TY=$T
		T=$Z
		Z=$Y
		Y=$X
		X=$typing
		echo $X $Y $Z $T "[CHIFFRE]"


	elif [[ "$typing" = "/" && "$Y" != 0 || "$typing" = "*" || "$typing" = "+" || "$typing" = "-" || "$typing" = "**" ]]	#Si c'est un opérateur défini (\ pas compatible avec 0) alors
	then
		last="op"																						#Dernière action était une opération
		undo_X=$X																						#On sauvegarde les variables qui seront consommées
		undo_TY=$Y																							
		echo -e "\n[opération: $X $typing $Y]"															#On effectue le calcul dans le premier étage et on décale
		X=$(($X $typing $Y))
		Y=$Z
		Z=$T
		T=0																								#Valeur étage le plus profond perdue car tout est remontée mais on a pas save l'ancienne
		echo $X $Y $Z $T
	elif [[ $typing = "u" ]]
	then
		case $last in
			"op")																						#Si on a réalisé une opération
				T=$Z
				Z=$Y
				Y=$undo_TY
				X=$undo_X
				last="undo"																				#Si UNDO est réutilisé alors ça ne marchera pas
				echo "$X $Y $Z $T [UNDO]"
				;;
			"nop")																						#Dernière action on a entré un chiffre
				X=$Y
				Y=$Z
				Z=$T
				T=$undo_TY
				last="undo"																				#On interdit la réutilisation de undo, car derniere action: undo
				echo "$X $Y $Z $T [UNDO]"
				;;
			"undo")
				echo "Vous ne pouvez pas utiliser undo plusieurs fois d'affilée."
				;;
			*)																							#Si on l'utilise dès le début
				echo "Vous devez d'abord faire une action."
				;;
		esac
		
	elif [[ $typing = "man" ]]
	then
		if [[ ! -f manuel_calculatrice.txt ]] #Si le manuel n'existe pas on propose de le créer
		then
		
			echo -e "Vous pouvez entrer n'importe quel chiffre et n'importe quel opérande. Lorsque vous entrez un opérande le calcul aura lieu sur les valeurs des deux paliers les plus hauts." > manuel_calculatrice.txt
			echo -e "La liste des opérandes possible est :\n\t+) Addition\n\t-) Soustraction\n\t*) Multiplication\n\t/) Division\n\t**) Puissance" >> manuel_calculatrice.txt
			echo -e "La liste des caractères spéciaux est:\n\t\"man\") Afficher le manuel\n\t\"u\") Annuler la dernière action\n\t\"q\") Quitter la calculatrice" >> manuel_calculatrice.txt
			cat manuel_calculatrice.txt
			echo "Voulez vous créer le fichier manuel_calculatrice.txt. Celui-ci sera consultable sans executer ce programme. [y or else]"
			read reponse
			if [[ $reponse = "y" ]]
			then
				echo "Le fichier manuel_calculatrice.txt est désormais disponible dans le dossier de votre programme"
			else
				rm manuel_calculatrice.txt
			fi
		else	#S'il existe on l'affiche simplement
			cat manuel_calculatrice.txt
		fi
	
	elif [[ $typing = "q" ]]																			#L'utilisateur souhaite quitter la calculatrice
	then
		echo "A bientôt!"
		break;																							#On sort avec break du while => fin du prog
	
	else
		echo "Vous tentez de diviser par 0 ou votre saisie n'est pas valide."
		echo $X $Y $Z $T
	fi
	
done

