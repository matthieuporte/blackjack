# - objets -
class String
  def is_integer?
    self.to_i.to_s == self
  end
end

class Paquet_de_cartes
	attr_reader :cartes_du_paquet

	def initialize(nb_decks)
		set_deck(nb_decks)
	end

	def set_deck(nb_decks)
		couleur = ['As']
		9.times { |i| couleur << i+2}
		#10.times { |i| couleur << 'As'}
		couleur += ['V','D','R']
		@cartes_du_paquet = []
		puts @cartes_du_paquet
		print couleur
		nb_decks.times {
			@cartes_du_paquet += couleur
		}
		shuffle_deck
	end

	def shuffle_deck
		index_max = @cartes_du_paquet.length()-1
		for i in 0..index_max
			position_random = rand(index_max)
			temporaire = @cartes_du_paquet[position_random]
			@cartes_du_paquet[position_random] = @cartes_du_paquet[i]
			@cartes_du_paquet[i] = temporaire
		end
	end
end

class Main
	#attrs
		attr_reader :role
		attr_reader :cartes_en_main
		attr_reader :busted
		attr_reader :done_playing
		attr_reader :blackjack
		attr_reader :is_same_card
		attr_reader :id_main
		attr_reader :mise_de_la_main
		attr_reader :premier_tour

	def initialize(role,mise=0,id=0,carte_de_base=nil)
		@cartes_en_main = []
		@premier_tour = true
		@role = role
		@busted = false
		@is_done_playing = false
		@blackjack = false
		@is_same_card = false
		@id_main = id
		@mise_de_la_main = mise
		if carte_de_base != nil
			pioche_forcee(carte_de_base)
		end
	end

	def passe_un_tour
		@premier_tour = false
	end

	def pioche(deck,partie)
		@cartes_en_main << deck.cartes_du_paquet.pop()
		if @cartes_en_main.length > 2
			@premier_tour = false
		end
		partie.afficher_table
	end

	def pioche_forcee(carte)
		@cartes_en_main << carte
	end

	def double_mise
		@mise_de_la_main *= 2
	end

	def split
		@is_same_card = false
		return @cartes_en_main.pop
	end

	def done_playing
		@is_done_playing = true
	end

	def is_same_card?
		if @cartes_en_main.length() == 2
			if @cartes_en_main[0] == @cartes_en_main[1]
				@is_same_card = true
			end
		end
	end

	def total
		somme = 0
		nb_cartes = 0
		as_en_main = false
		@cartes_en_main.each { |carte| 
			if carte == 'As'
				somme += 1
				as_en_main=true
			elsif ['R','V','D'].include?(carte)
				somme += 10
			else
				somme += carte
			end
			nb_cartes += 1
		}
		if as_en_main and nb_cartes == 2 and somme+10 == 21
			@blackjack = true
		end
		if as_en_main and somme + 10 <= 21 and !@is_done_playing
			if @role == 'croupier'
				return (somme+10).to_s()
			else
				return "#{somme}/#{somme+10}"
			end
		else
			if somme > 21
				@busted = true
			end
			if as_en_main and @is_done_playing and somme + 10 <=21
				return (somme+10).to_s()
			else
				return somme.to_s()
			end

		end
	end
end

class Partie
	attr_reader :capital,:mise,:nb_decks,:deck,:joueur,:croupier,:coeff_sleep,:banqueroute,:nb_manches,:last_id_given

	def initialize
		@capital = 0
		@mise = 0
		@nb_manches = 0
		@nb_decks = 5
		@banqueroute = false
		@last_id_given = 0
		@deck = Paquet_de_cartes.new(nb_decks)
		@coeff_sleep = 0.1

		espace(30)
		puts "            .     '     ,"
		puts "              _________"
		puts "           _ /_|_____|_\\ _"
		puts "             '. \\   / .'"
		puts "               '.\\ /.'"
		puts "                 '.'"
		espace(2)
		puts " - - - - - - - - - - - - - - - - - - - -"
		print " - - - "
		print "Bienvenue au Ruby Casino !"
		puts " - - -"
		puts " - - - - - - - - - - - - - - - - - - - -"
		espace(3)
		sleep(1*@coeff_sleep)
		print_text(" - vous rejoignez la table de blackjack -")
		print_text(" - Le casino paye 3 pour 2 - mise minimum 5$ - #{nb_decks} decks dans le sabot -\n\n")
		sleep(1*@coeff_sleep)
		print_text("   |REGLES|")
		print_text("|c pour carte|")
		print_text("|s pour servi|")
		print_text("|d pour doubler|")
		print_text("|p pour partager|")
		print_text("|exit pour quitter|")
		sleep(1*@coeff_sleep)
		print_text("\n\n",false,0.05)
		print "[croupier] : " 
		print_text("combien au change ? ",false)
		@capital = gets.chomp.to_i
		#@capital = 50
		while !@capital.to_s.is_integer?
			if @capital == 'exit'
				fin
			end
			print "[croupier] : "
			print_text("Veuillez entrer un nombre entier")		
			print "[croupier] : " 
			print_text("combien au change ? ",false)
			@capital = gets.chomp.to_i	
		end
		print "[croupier] : " 
		print_text("#{capital}$ au change.")
		sleep(0.3*@coeff_sleep)
		mise
	end

	def print_text(string,retour=true,slow=0.0002)
		string.each_char { |c| 
			print c
			sleep(slow)
		}
		if retour
			print"\n"
		end
	end


	def espace(taille)
		print "\n" * taille
	end

	def mise(skip = false)
		if @capital < 5
			print_text("Vous n'avez plus les fond nécessaires pour jouer...")
			sleep(1*@coeff_sleep)
			print_text("Vous vous êtes ruinés en #{nb_manches} manches")
			sleep(1*@coeff_sleep)
			print_text("Ruby casino vous souhaite bonne fortune par la suite et a hâte de vous revoir !")
			sleep(1*@coeff_sleep)
			exit
		end
		unless skip
			puts "(#{@capital}$)"
			print "[croupier] : "
			print_text("Faites vos jeux ! ",false)
		end
		@mise = gets.chomp
		#@mise = 5
		if @mise == 'exit'
			fin
		elsif !@mise.is_integer?
			print "[croupier] : "
			print_text("Veuillez entrer un nombre entier")
			mise(true)
		else
			@mise = @mise.to_i
			if @mise > @capital
				print "[croupier] : "
				print_text("Vous n'avez pas les fonds necessaires.")
				puts "capital : #{@capital}$"
				sleep(1*coeff_sleep)
				mise(true)
			elsif @mise < 5
				print "[croupier] : "
				print_text("La mise minimale est de 5$")
				sleep(1*coeff_sleep)
				mise(true)
			else
				puts "(#{@mise}$) en jeu"
				@capital -= @mise
				sleep(1*@coeff_sleep)

				print "[croupier] : "
				print_text("rien ne va plus . . .",false)
				print "\n[croupier] : "
				print_text("Les jeux sont faits !",true,0.01)
				sleep(1*@coeff_sleep)
				manche
			end
		end
	end

	def afficher_table(sleeptime=1)
		espace(30)
		puts "          [Table de BlackJack] (#{@deck.cartes_du_paquet.length})\n"
		puts "          ____________________"
		puts "      - - - - -          - - - - -"
		puts "   - - - - -                - - - - -"
		[@croupier,@joueur].each { |mains|
			mains.each { |main|
				jeu = ''
				main.cartes_en_main.each {|carte| jeu += "[#{carte}]"}
				tot = main.total
				main_joueur = false
				if main.role == 'joueur'
					main_joueur = true
				end

				print "- - - "
				if !main_joueur
					print "[croupier] "
				elsif @joueur.length > 1
					print "[main #{main.id_main + 1}] "
				else
					print "[joueur] "
				end

				print jeu + " "

				if main.blackjack
					print "(blackjack) "
				else
					print "(#{tot}) "
				end

				if main_joueur
					print "(#{main.mise_de_la_main}$)"
				end

				if main.busted
					print 'BUST'
				end

				print "\n"

				unless main_joueur
					puts "-"
				end
			} 
		}
		puts "   - - - - -                - - - - -"
		puts "      - - - - -          - - - - -"
		puts "          ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
		puts "          (#{capital}e)"
		print"\n"
		sleep(sleeptime*@coeff_sleep)
	end

	def manche
		@nb_manches += 1
		@croupier = [Main.new('croupier')]
		@joueur = [Main.new('joueur',@mise)]
		@joueur[0].pioche(@deck,self)
		@croupier[0].pioche(@deck,self)
		@joueur[0].pioche(@deck,self)
		if @joueur[0].blackjack
			puts "vous faites un blackjack !"
			sleep(1*@coeff_sleep)
			@joueur[0].done_playing
			tour_croupier
		else
			action
			if @joueur.length == 1 and @joueur[0].busted
				fin_manche
			else
				tour_croupier
			end
		end
	end

	def action(id_main=0,aide = false)
		mise_de_la_main = @joueur[id_main].mise_de_la_main
		if aide
			print_text("\n\n   |REGLES|")
			print_text("|c pour carte|")
			print_text("|s pour servi|")
			print_text("|d pour doubler|")
			print_text("|p pour partager|")
			print_text("|exit pour quitter|\n\n")
			sleep(1*@coeff_sleep)
		end
		print_text("le croupier vous regarde ",false,0.01)
		if @joueur.length > 1
			print_text("(main #{id_main + 1})")
		else
			#print "\n"
		end
		action_joueur = gets.chomp
		case action_joueur
		when 'exit'
			fin
		when 'c'
			afficher_table(0.5)
			@joueur[id_main].pioche(@deck,self)
			@joueur[id_main].passe_un_tour
			if !@joueur[id_main].busted
				action(id_main)
			else 
				@joueur[id_main].done_playing
			end
		when 's'
			@joueur[id_main].done_playing
		when 'd'
			if @joueur[id_main].premier_tour
				if mise_de_la_main <= @capital
					@capital -= mise_de_la_main
					@joueur[id_main].double_mise
					print_text("Vous doublez ! Votre mise est maintenant de (#{@joueur[id_main].mise_de_la_main}$)")
					sleep(1*coeff_sleep)
					afficher_table(0.5)
					@joueur[id_main].pioche(@deck,self)
					@joueur[id_main].done_playing
				else
					print_text("Vous n'avez pas asser d'argent pour doubler, vous avez #{@capital}$ en tout et il vous aurait fallu au moins #{mise_de_la_main}$ en plus ")
					sleep(1*coeff_sleep)
					action(id_main)
				end
			else
				print_text("vous ne pouvez doubler qu'a premier tour...")
			end
		when 'p'
			if @joueur[id_main].is_same_card?
				if mise_de_la_main*2 <= @capital
					@capital -= mise_de_la_main
					@last_id_given += 1 
					nouvel_id = @last_id_given
					@joueur << Main.new('joueur',mise_de_la_main,nouvel_id,@joueur[id_main].split)
					afficher_table
					@joueur[id_main].pioche(@deck,self)
					afficher_table
					action(id_main,false)
					afficher_table
					@joueur[nouvel_id].pioche(@deck,self)
					afficher_table
					action(nouvel_id,false)
				else	
					print_text("Vous n'avez pas asser d'argent pour partager, vous avez #{@capital}$ en tout et il vous aurait fallu au moins #{mise_de_la_main*2}$")
					sleep(1*coeff_sleep)
					action(id_main)
				end
			else
				print_text("Vous devez avoir deux fois la même carte pour partager")
				sleep(1*coeff_sleep)
				action(id_main)
			end
		else
			action(id_main,true)
		end
	end

	def tour_croupier
		afficher_table(0.5)
		while @croupier[0].total.to_i < 17
			@croupier[0].pioche(@deck,self)
		end
		for n in 0...@joueur.length
			if @joueur.length > 1
				fin_manche(n,true)
			else
				fin_manche
			end
		end
	end

	def fin_manche(id_main = 0,multiple_hands = false)
		if multiple_hands
			print_text("(main #{id_main+1}) ",false)
		end
		if @joueur[id_main].busted
			print_text("Bust...",false)
			lose(id_main)
		elsif @joueur[id_main].blackjack and @croupier[0].blackjack
			print_text("Egalite sur blackjack !!!",false)
			draw(id_main)
		elsif @joueur[id_main].blackjack
			print_text("Vous faites un blackjack, Félicitations !!!",false)
			win(id_main,1.5)
		elsif @croupier[0].blackjack
			print_text("Le casino gagne sur blackjack",false)
			lose(id_main)
		elsif @croupier[0].busted
			print_text("Le croupier a bust, vous gagnez cette manche",false)
			win(id_main)
		elsif @joueur[id_main].total < @croupier[0].total
			print_text("Le casino gagne : #{@joueur[id_main].total} < #{@croupier[0].total}",false)
			lose(id_main)
		elsif @joueur[id_main].total > @croupier[0].total
			print_text("#{@joueur[id_main].total} > #{@croupier[0].total}",false)
			win(id_main)
		elsif @joueur[id_main].total == @croupier[0].total
			print_text("Egalité : #{@joueur[id_main].total} = #{@croupier[0].total}",false)
			draw(id_main)
		else
			print "situation inconnue"
		end
		if @deck.cartes_du_paquet.length < 52
			@deck.set_deck(5)
			print_text("Melange du deck",false)
			print_text(".....",true,0.3)
			espace(30)
			print_text("Melange du deck",false)
			print_text(".....",true,0.3)
			print_text("La partie peut continuer !")
			sleep(1*coeff_sleep)
		end
	end

	def win(id_main,coeff = 1)
		print_text("\nVous gagnez #{@joueur[id_main].mise_de_la_main*coeff}$")
		@capital += @joueur[id_main].mise_de_la_main*coeff + @joueur[id_main].mise_de_la_main
	end

	def draw(id_main)
		print_text("\nVous recuperez votre mise de  #{@joueur[id_main].mise_de_la_main}$")
		@capital += @joueur[id_main].mise_de_la_main
	end

	def fin
		print_text(" - Vous quittez la table avec #{@capital}$ en poche après #{@nb_manches} manches - ")
		sleep(1*@coeff_sleep)
		print_text("Ruby casino vous souhaite bonne fortune par la suite et a hâte de vous revoir !")
		sleep(1*@coeff_sleep)
		exit
	end

	def lose(id_main)
		print_text("\nVous perdez votre mise de #{@joueur[id_main].mise_de_la_main}$")
	end
end

game = Partie.new

while true
	game.mise
end



#bugs

# les fonctions ne s'arretent jamais de tourner 
# les actions ne sont proposees que pour la premiere main