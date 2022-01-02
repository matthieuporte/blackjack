import random
import time

pactole = 100
nb_paquets = 6
vitesse_jeu = 1
nb_espace = 40
mise_min = 5
mise_max = 1000
mise = [0]
blackjack = [False]
cartes_identiques = [False]
nb_manches = 0

actions = ['c','s','d','p','+','-','*','/']
couleur = ['As','2','3','4','5','6','7','8','9','10','J','Q','K']
sabot = couleur*4*nb_paquets

def tirer(main,id=0):
	global sabot
	main[id].append(sabot.pop())

def melanger(tableau):
	dernier_element_non_melange = len(tableau)-1
	for i in range(dernier_element_non_melange-1):
		h = random.randint(0,dernier_element_non_melange)
		sauve = tableau[dernier_element_non_melange]
		tableau[dernier_element_non_melange] = tableau[h]
		tableau[h] = sauve
		dernier_element_non_melange -= 1

def partie():
	global pactole
	regles()
	melanger(sabot)
	time.sleep(vitesse_jeu/3)
	while True:
		try:
			pactole = int(input('Combien au change ? : '))
			break
		except ValueError:
			print("Veuillez entrer un nombre")  
			continue
	print()
	manche()

def regles():
	espace()
	print('Bienvenue au casino !')
	print('Voici les regles du blackjack :')
	print()
	print('--- Regles ---')
	print('mise min ' + str(mise_min))
	print('mise max ' + str(mise_max))
	print('| actions |')
	print('s ou - pour servi')
	print('c ou + pour carte')
	print('d ou * pour double')
	print('p ou / pour partager')
	print('--- Regles ---')
	print()

def choix_action(main,i=1,id_main=0):
	global action_encours,mise,pactole,cartes_identiques
	if blackjack[id_main]:
		print('blackjack !')
		return
	numero_main = ''
	if len(main) > 1:
		numero_main = '(main ' + str(id_main+1) +')'
	
	while True:
		try:
			action = input('Que souhaitez vous faire ? ' + numero_main + ' : ')
			if action not in actions:
				print('| actions |')
				print('s ou - pour servi')
				print('c ou + pour carte')
				print('d ou * pour double')
				print('p ou / pour partager')
				continue
			elif action == 'd' and i != 1 or action == '*' and i != 1:
				print("Vous ne pouvez doubler qu'au premier tour")
				continue
			elif action == 'p' and pactole < mise[id_main] or action == '/' and pactole < mise[id_main]:
				print("Vous n\'avez pas asser d\'argent pour partager")
				continue
			elif action == 'p' and i != 1 or action == '/' and i != 1:
				print("Vous ne pouvez partager qu'au premier tour")
				continue
			elif action == 'p' and not cartes_identiques[id_main] or action == '/' and not cartes_identiques[id_main]:
				print("Les cartes doivent etre identiques afin de partager")
				continue
			elif action == 'd' and pactole < mise[id_main] or action == '*' and pactole < mise[id_main]:
				print("Vous n\'avez pas asser d\'argent pour doubler")
				continue
			else:
				break
		except ValueError:
			print("erreur")  
			continue

	if action == 'p' or action == '/':
		action_encours = 'partager'
		pactole = pactole - mise[id_main]
		nouvelle_main(main)
		mise.append(mise[id_main])
		id_nouvelle_main = len(main)-1
		main[id_nouvelle_main].append(main[id_main].pop())
		cartes_identiques[id_main] = False
		afficher_table()
		tirer(main,id_main)
		afficher_table()
		choix_action(main,1,id_main)
		afficher_table()
		tirer(main,id_nouvelle_main)
		afficher_table()
		choix_action(main,1,id_nouvelle_main) 

	if action == 'd' or action == '*':
		pactole = pactole - mise[id_main]
		print('vous doublez votre mise')
		time.sleep(vitesse_jeu)
		mise[id_main] = mise[id_main]*2
		action_encours = 'double'
		tirer(main,id_main)
		if total(main,id_main) > 21:
			action_encours += ' Bust'
		afficher_table()	
	if action == 'c' or action == '+':
		action_encours = 'carte'
		tirer(main,id_main)
		if total(main,id_main) > 21:
			action_encours = 'Bust'
			afficher_table()
			return
		else:
			afficher_table()
			choix_action(main,i+1,id_main)
	elif action == 's' or action == '-':
		action_encours = 'servi'

	return

def val_carte(carte):
	if EstUnNombre(carte):
		return int(carte)
	elif carte == 'As':
		return 11
	else: 
		return 10

def EstUnNombre(stringATester):
	for i in stringATester:
		if i not in '0123456789':
			return False
	return True

def total(tableau,id_tableau=0,AllAsValues=False):
	somme = 0
	As = False
	for i in tableau[id_tableau]:
		somme += val_carte(i)
		if i == 'As':
			As = True
	if As:
		if somme > 21:
			return somme-10
		elif somme == 21:
			return 21
		elif AllAsValues: 
			return [somme-10,somme]
	return somme

def d(texte='###'):
	print(texte)
				
def afficher_main(main,role,id_main=0):
	global blackjack,cartes_identiques

	cartes = ''
	string_main = ''

	if role == 1: # si la main appartient au joueur

		if len(main) > 1: # on affiche le numero de la main si il y a plusieurs mains
			string_main += 'joueur ' + '(' + str(id_main+1) + ') : '
		else:
			string_main += 'joueur : '

		# on determine si les cartes de la main que l'on affiche sont de valeur identiques
		if total(main,id_main)/2 == val_carte(main[id_main][0]): 
			cartes_identiques[id_main] = True

	else: #si la main appartient au croupier
		string_main += 'croupier : '

	# on determine si il y a blackjack ou non
	if total(main,id_main) == 21 and len(main[id_main]) == 2:
		total_main = 'blackjack'
		if role == 1:
			blackjack[id_main] = True

	# on determine si la main a plusieurs valeurs possibles
	elif type(total(main,id_main,True)) is list:
		total_main = str(total(main,id_main,True)[0]) + "/" + str(total(main,id_main,True)[1])
	else:
		total_main = str(total(main,id_main))

	#on imprime toutes les cartes de la main
	for i in main[id_main]:
		cartes += '[' + str(i) + ']'
	string_main += cartes + ' (' + total_main + ')'
	if total(main,id_main) > 21:
		string_main += '(Bust)'

	if role == 1:
		string_main += ' (' + str(mise[id_main]) + 'e)' 

	# on affiche la string ainsi finie
	print(string_main)

def espace():
	for i in range(nb_espace):
		print('.')

def nouvelle_main(main):
	main.append([])
	blackjack.append(False)
	cartes_identiques.append(False)

def afficher_table():
	nb_mains = len(main_joueur)
	espace()	
	print('- - - - -')
	afficher_main(main_croupier,2)
	print()

	# on affiches les differentes mains du joueur
	for i in range(nb_mains):
		afficher_main(main_joueur,1,i)
	print('- - - - -')
	time.sleep(vitesse_jeu)

def reset_table():
	global main_joueur,main_croupier,blackjack,cartes_identiques
	main_joueur = []
	main_croupier = []
	blackjack = [False]
	cartes_identiques = [False]

def manche():
	global pactole,main_joueur,main_croupier,mise,action_encours,sabot,nb_manches
	nb_manches += 1
	action_encours = 'service'
	reset_table()

	if len(sabot) < 52:
		sabot = couleur*4*nb_paquets
		melanger(sabot)
		print('melange des cartes...')
		time.sleep(vitesse_jeu*2)


	print('- - - - -')
	print('| (' + str(pactole) + 'e) |') 
	print('- - - - -')

	while True:
		try:
			mise = [int(input('faites vos jeux : '))]
			if mise[0] > pactole:
				print("Vous n'avez pas asser d'argent")
				continue
			elif mise[0] < mise_min:
				print("la mise minimum est " + str(mise_min) + "e")
				continue
			elif mise[0] > mise_max:
				print("la mise maximum est " + str(mise_max) + "e")
				continue
			else:
				print()
				print('(' + str(mise[0]) + 'e)')
				print()
				break
		except ValueError:
			print("Veuillez entrer un nombre")  
			continue

	print('Rien ne va plus....')
	time.sleep(vitesse_jeu/2)
	print('Les jeux sont faits !')
	time.sleep(vitesse_jeu*1.5)
	pactole = pactole - mise[0]
	nouvelle_main(main_joueur)
	nouvelle_main(main_croupier)
	tirer(main_joueur)
	afficher_table()
	tirer(main_croupier)
	afficher_table()
	tirer(main_joueur)
	afficher_table()

	# choix de l'action a effectuer
	choix_action(main_joueur)

	numero_main = ''
	for y in range(len(main_joueur)):
		if len(main_joueur) > 1:
			numero_main = ' (main ' + str(y+1) +')'
		if total(main_joueur,y) <= 21: 
			while total(main_croupier) < 17:
				tirer(main_croupier)
				afficher_table()

			if total(main_croupier) > 21:
				print('Bust du croupier')
				print('vous gagnez ' + str(mise[y]) + 'e' + numero_main)
				pactole += mise[y]*2
			else:
				if total(main_joueur,y) > total(main_croupier):
					if blackjack[y]:
						print('blackjack !')
						print('vous gagnez ' + str(mise[y]*1.5) + 'e' + numero_main)
						pactole += mise[y]*2.5
					else:
						print('vous gagnez ' + str(mise[y]) + 'e : (' + str(total(main_joueur,y)) + ') > (' + str(total(main_croupier)) + ') ' + numero_main)
						pactole += mise[y]*2
				elif total(main_joueur,y) < total(main_croupier):
					print('vous perdez votre mise : (' + str(total(main_croupier)) + ') > (' + str(total(main_joueur,y)) + ') ' + numero_main)
				else:
					if blackjack[y] and total(main_croupier) == 21 and len(main_croupier[0]) != 2:
						print('blackjack !')
						print('vous gagnez ' + str(mise[y]*1.5) + 'e' + numero_main)
						pactole += mise[y]*2.5
					else:
						print('égalité' + numero_main)
						pactole += mise[y]
		else:
			print('Bust (' + str(total(main_joueur,y)) + ') vous perdez votre mise' + numero_main)

	if pactole >= mise_min:
		manche()
	else:
		print('vous avez fait Banqueroute :( ')
		print('en ' + str(nb_manches) + ' manches')
		time.sleep(3)

partie()
