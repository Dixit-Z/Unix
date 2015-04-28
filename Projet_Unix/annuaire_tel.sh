#!/bin/bash

###############################################################################################################################################################################
#~ 													Annuaire - TRINTA Bruno - IATIC3 - Projet UNIX
###############################################################################################################################################################################

#~ Fonction qui ajoute un contact, on read le nom et on le créer dans le dossier contact_list, puis on read son num

function ajout_contact(){
	
	if [[ $# = 1 ]]														#Already got a name from a previous function if there is an argument.
	then
		nom=$1
	else
		echo "Nom du contact:"
		read nom
		if [[ -f contact_list/$nom ]]									#We've already check if we're calling this function with an argument.
		then															#That would be why we're here actually...
			echo "$nom existe déjà."
			return 1													#If it exists already, get out of this function
		fi
	fi
	if [[ "$nom" = [a-Z,0-9][a-Z,0-9]* ]]
	then
		touch contact_list/$nom
		echo -e "Le contact a bien été créé.\nVeuillez entrer un numéro de téléphone pour $nom :"
		read numero
		echo $numero > contact_list/$nom
	fi
}

#~ Fonction utile lorsque l'utilisateur cherche un contact qui n'existe pas. On lui propose de le créer avec un nouvel ajout_contact.

function contact_inexistant(){
	echo "$1 n'existe pas dans le répertoire. Voulez vous le créer ? [y or else]"
	read reponse
	if [[ $reponse = 'y' ]]
	then
		ajout_contact $1
	fi
}

#~ On dit à l'utilisateur le nb de contact via wc -w qui prend en paramètre la liste des files de contact_list => du répertoire. Nb de mots = nb de contact.
#~ On demande s'il veut l'affichage. Si oui, alors on affiche la liste avec ls.

function liste_contacts(){
	nb_contacts=`ls contact_list|wc -w`
	echo "$nb_contacts contacts dans le répertoire. Les afficher ? [y or else]"
	read reponse
	if [[ $reponse = 'y' ]]	
	then
		ls contact_list
	fi
}

#~ L'utilisateur recherche un numéro. On parcourt tous les files de contact_list (donc du répertoire) pour savoir si un contient le numéro (test avec fgrep).
#~ Si c'est le cas alors on écrit dans tmp (qui a été préalablement effacé s'il existait) le nom du contact qui a le numéro.
#~ Si tmp contient plus d'une ligne de texte on propose à l'utilisateur de supprimer un contact. (Deux contacts ou plus ont le même numéro)

function recherche_num(){
	echo "A qui appartient le numero :"
	read numero
	
	if [[ -f  tmp ]]
	then
		rm tmp
	fi
	
	for i in `ls contact_list`
	do
		if [[ `grep ^$numero$ contact_list/$i` ]]
		then
			echo "$i a ce numéro." 
			echo "$i" >> tmp
		fi
	done
	if [[ -f tmp ]]
	then
		if [[ `cat tmp|wc -l` > 1 ]]
		then
			echo "Voulez-vous supprimer un des contacts ayant ce numéro ? [y or else]"
			read reponse
			if [[ $reponse = 'y' ]]
			then
				suppr_contact tmp
			fi
		fi
	else																#If tmp doesn't exist it means nobody has this number. Want to create a new file?
		echo "Personne dans votre répertoire n'a ce numéro. Voulez-vous créer un nouveau contact ? [y or else]"
		read reponse
		if [[ $reponse = 'y' ]]
		then
			ajout_contact
		fi
	fi
}

#~ On cherche à savoir s'il existe le file $nom (nom du contact recherché par l'utilisateur) dans contact_list (le répertoire). S'il existe on affiche son contenu (num).
#~ Si le contact cherché n'existe pas, on lui propose de le créer.

function recherche_nom(){
	echo "Vous cherchez :"
	read nom
	if [[ -f contact_list/$nom ]]
	then
		cat contact_list/$nom
	else
		contact_inexistant $nom
	fi
}

#~ Si le contact à modifier n'existe pas, on lui propose de le créer.
#~ Sinon, on écrase le fichier $nom dans contact_list pour écrire le nouveau numéro dedans.

function modif_num(){
	echo "Contact à modifier :"
	read nom
	if [[ -f contact_list/$nom ]]
	then
		echo "Nouveau numéro :"
		read numero
		echo $numero > contact_list/$nom	
	else
		contact_inexistant $nom
	fi
}

#~ On propose à l'utilisateur d'afficher ses contacts. On lui demande le nom de la personne à supprimer. Si une fiche correspondant au nom entré existe on la supprime.
#~ Sinon, on ne propose pas à l'utilisateur de créer une fiche, on le prévient que ce contact n'existe pas.

function suppr_contact(){												#We should use two functions, one with args, and the other one without.
	if [[ $# = 1 ]]														#So we'll be able to modify tmp and call suppr_contact over and over again.
	then
		echo "Ces personnes ont le même numéro:"
		cat $1
	else
		echo "Afficher la liste des contact ? [y or else]"
		read reponse
		if [[ $reponse = 'y' ]]
		then
			ls contact_list
		fi
	fi		
	echo "Contact à supprimer :"
	read nom
	if [[ -f contact_list/$nom ]]
	then
		rm contact_list/$nom
		echo "$nom a bien été supprimé."
	else
		echo "$nom n'existe pas."
	fi
	
	if [[ $# = 1 ]]
	then
		sed -i "/"$nom"/d" $1
		nb=`cat $1|wc -l`
		if [[ $nb > 1 ]]
		then
			echo "Il y a toujours $nb personnes possédant le même numéro. Continuer à supprimer ? [y or else]"
			read reponse
			if [[ $reponse = 'y' ]]
			then
				suppr_contact $1
			fi
		else
			echo "Il ne reste plus qu'un contact avec le numéro."
			cat $1
		fi
	fi
	
}

#~ On vérifie simplement si le directory contact_list (donc le répertoire) existe. Si ce n'est pas le cas, on le créer.

function verif_repertoire(){
	if [[ ! -d contact_list ]]
	then
		mkdir contact_list
	fi
}

#~ Informations sur l'utilisation du script.

function presentation(){
	echo -e "\n\n\t\t\tAnnuaire téléphonique\n\n\tAfin de faire réapparaitre le menu vous pourrez entrer un choix vide.\n\n"
}

function import_contacts(){
	echo "Attention il faudra alors donner l'adresse du dossier contenant les contacts depuis le dossier du script!"
		echo "Entrez le chemin relatif :"
		read path
	if [[ ! -d $path ]]												#If the directory does exist then for i in ls $path, we copy everything is this directory.
	then
		echo "Le répertoire n'a pas été trouvé. Vérifier l'adresse: $path"
	else
		for i in `ls $path`
		do
			if [[ -f contact_list/$i ]]
			then
				echo "Le contact $i existe déjà, le remplacer ? [y or else]"
				read answer
				if  [[ $answer = 'y' ]]
				then
					cp $path/$i contact_list
				fi
			else
					cp $path/$i contact_list
			fi
		done
	fi
}
#~ On change le prompt à notre guise.
	
PS3="Votre choix :"

choices=("Ajouter une fiche" "Liste des contacts" "Rechercher par nom" "Rechercher par num" "Modifier un num" "Supprimer un contact" "Importer un repertoire" "Quitter")
presentation
verif_repertoire

#~ On utilise la boucle select, qui propose les choix présents dans la liste définie précedemment choices.
#~ Si l'utilisateur veut quitter le programme -> break -> On sort de la boucle. Lorsque l'on quitte le programme on détruit le fichier temporaire tmp.
#~ Autrement, il choisit un autre choix qui fait appel aux fonctions définies. On vérifie avec un case les choix de l'utilisateur.

select USERCHOICE in "${choices[@]}"
	do
		case $USERCHOICE in
			"Ajouter une fiche")
				ajout_contact
				;;
			"Liste des contacts")
				liste_contacts
				;;
			"Rechercher par nom")
				recherche_nom
				;;
			"Rechercher par num")
				recherche_num
				;;
			"Modifier un num")
				modif_num
				;;
			"Supprimer un contact")
				suppr_contact
				;;
			"Importer un repertoire")
				import_contacts
				;;
			"Quitter")
				if [[ -f tmp ]]
				then
					rm tmp
				fi
				break
				;;
			*)
				echo -e "Vous n'avez pas entré un choix correct. Veuillez ré-essayer.\n\n"
				;;
		esac
	done
