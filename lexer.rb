=begin
 *  UNIVERSIDAD SIMÓN BOLÍVAR
 *  Archivo: lexer.rb
 *
 *  Contenido:
 *          Analisis lexico de un archivo
 *
 *  Creado por:
 *			Genessis Sanchez	11-10935
 *          Daniela Socas		11-10979
 *
 *  Último midificación: 27 Mayo de 2015
=end

class Token
	# Creamos metodos para acceder a los atributos privados de la clase.
	attr_accessor :id
	attr_accessor :symbol
	attr_accessor :position
	def initialize (id = nil, symbol, position)
		@id = id
		@symbol = symbol
		@position = position
	end

	def idAndValue
		return [@id, @symbol]
	end
end

class Lexer
	attr_accessor :tokensList
=begin
	atr:   @tokensList: lista de tokens validos del lenguaje.
		   @errList: lista de tokens no validos del lenguaje.
=end	
=begin
	funcion: initialize: inicializa la clase Lexer.
=end
	def initialize
		@tokensList = Array.new
		@tokensAux = Array.new
		@errList = Array.new
		errComm = false
	end
=begin
	funcion: identifier: identifica los tokens validos e invalidos en un archivo.
	@param: file: archivo a analizar.
=end
	def identifier(file)
		lineNum = 0
		commline = 0 
		commcol = 0 
		errComm = false #pen

		file.each_line do |line|
			# En cada iteracion (salto de linea), el numero de linea aumenta.
			# y el numero de columna vuelve a 1.
			lineNum += 1
			colNum = 1
			# Cuando lo que queda de la linea es un salto de pagina, pasamos a la
			# proxima linea (arriba)
			while line != ""

				#Revisa que no esta leyendo dentro de un comentario.
				if errComm == true then	
					case line
					#Si encuentra el fin del comentario no da error. 	
					when /(.*?)\-}/		
						errComm = false
						word = line[/(.*?)\-}/]
						line = line.partition(word).last
						colNum += word.size

					else 	
						#Sigue buscando en lineas el fin del comentario
						if line =~ /^[\s]+/
							word = line[/^[\s]+/] 
						else	
							word = line[/(.*)/] 
						end
						line = line.partition(word).last
						colNum += word.size
						next 
					end
				else
					# Este case sirve para matchear regexs con los 'when' en lo que quede de linea.
					case line

					#Si encuentra {- ignora todo hasta encontrar -}, si no lo encuentra da error. 
					when /^{\-/		
						errComm = true
						word = line[/^{\-/]
						commcol = colNum
						line = line.partition(word).last	
						colNum += word.size		
						commline = lineNum

					# Este es para las tabulaciones, las cuenta como 4 espacios. 
					when /^\t+/
						word = line[/^\t+/]
						line = line.partition(word).last
						colNum += 4
				
					# Este es para los espacios en blanco o saltos de linea.
					when /^\s+/
						word = line[/^\s+/]
						line = line.partition(word).last
						colNum += word.size

					# AGREGANDO TOKENS LIST.
					# Va a matchear con read. 
					when /^read/
						word = line[/^read/]
						line = line.partition(word).last
						@tokensList << Token.new(:READ, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear con write. 
					when /^write/
						word = line[/^write/]
						line = line.partition(word).last
						@tokensList << Token.new(:WRITE, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear con true, tipo boolean llamado TRUE. 
					when /^true/
						word = line[/^true/]
						line = line.partition(word).last
						@tokensList << Token.new(:TRUE, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear con false, tipo boolean llamado FALSE. 
					when /^false/
						word = line[/^false/]
						line = line.partition(word).last
						@tokensList << Token.new(:FALSE, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todas las palabras, son de tipo IDENTIFIER. 
					# \w = [a-zA-Z0-9_]
					when /^[a-zA-Z]\w*/
						word = line[/^[a-zA-Z]\w*/]
						line = line.partition(word).last
						@tokensList << Token.new(:IDENTIFIER, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos los numeros, son de tipo NUMBER.
					# \d = [0-9]. En caso de exceder el limite es un token no valido. 
					when /^\d+/
						word = line[/\d+/]
						if word.to_i > 2147483647
							@errList << Token.new("", word, [lineNum, colNum])
							line = line.partition(word).last
						else
							line = line.partition(word).last
							@tokensList << Token.new(:NUMBER, word, [lineNum, colNum])
						end
						colNum += word.size

					# Va a matchear los @, son de tipo AT. 
					when /^[@]/
						word = line[/^[@]/]
						line = line.partition(word).last
						@tokensList << Token.new(:AT, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos !, son de tipo EXCLAMATION MARK. 
					when /^[!]/
						word = line[/^[!]/]
						line = line.partition(word).last
						@tokensList << Token.new(:EXCLAMATION_MARK, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos los .., son de tipo TWO POINTS.
					when /^\.\./
						word = line[/^\.\./]
						line = line.partition(word).last
						@tokensList << Token.new(:TWO_POINTS, word, [lineNum, colNum])
						colNum += word.size	
						
					# Va a matchear todos }, es de tipo LCURLY. 
					when /^[{]/
						word = line[/^[{]/]
						line = line.partition(word).last
						@tokensList << Token.new(:LCURLY, word, [lineNum, colNum])
						colNum += word.size					

					# Va a matchear todos }, es de tipo RCURLY. 
					when /^[}]/
						word = line[/^[}]/]
						line = line.partition(word).last
						@tokensList << Token.new(:RCURLY, word, [lineNum, colNum])
						colNum += word.size						

					# Va a matchear todos ), es de tipo RPARENTHESIS. 
					when /^[)]/
						word = line[/^[)]/]
						line = line.partition(word).last
						@tokensList << Token.new(:RPARENTHESIS, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos (, es de tipo LPARENTHESIS. 
					when /^[(]/
						word = line[/^[(]/]
						line = line.partition(word).last
						@tokensList << Token.new(:LPARENTHESIS, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos ], es de tipo RBRACKET
					when /^(\])/
						word = line[/(\])/]
						line = line.partition(word).last
						@tokensList << Token.new(:RBRACKET, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos [, es de tipo LBRACKET. 
					when /^\[/
						word = line[/^\[/]
						line = line.partition(word).last
						@tokensList << Token.new(:LBRACKET, word, [lineNum, colNum])
						colNum += word.size		

					# Va a matchear todos |, es de tipo PIPE. 
					when /^[|]/
						word = line[/^[|]/]
						line = line.partition(word).last
						@tokensList << Token.new(:PIPE, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos ;, es de tipo SEMICOLON. 
					when /^[;]/
						word = line[/^[;]/]
						line = line.partition(word).last
						@tokensList << Token.new(:SEMICOLON, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos ?, es de tipo QUESTIONMARK. 
					when /^[\?]/
						word = line[/^[\?]/]
						line = line.partition(word).last
						@tokensList << Token.new(:QUESTION_MARK, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos -, es de tipo MINUS. 
					when /^[-]/
						word = line[/^[-]/]
						line = line.partition(word).last
						@tokensList << Token.new(:MINUS, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos $, es de tipo ROTATION. 
					when /^\$/
						word = line[/^\$/]
						line = line.partition(word).last
						@tokensList << Token.new(:ROTATION, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos ', es de tipo TRANSPOSITION. 
					when /^'/
						word = line[/^'/]
						line = line.partition(word).last
						@tokensList << Token.new(:TRANSPOSITION, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos ^, es de tipo boolean, llamado NEGATION. 
					when /^\^/
						word = line[/^\^/]
						line = line.partition(word).last
						@tokensList << Token.new(:NEGATION, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos \/, es de tipo boolean, llamado OR. 
					when /^\\\//
						word = line[/^\\\//]
						line = line.partition(word).last
						@tokensList << Token.new(:OR, word, [lineNum, colNum])
						colNum += word.size		

					# Va a matchear todos /\, es de tipo boolean, llamado AND. 
					when /^\/\\/
						word = line[/^\/\\/]
						line = line.partition(word).last
						@tokensList << Token.new(:AND, word, [lineNum, colNum])
						colNum += word.size		
	

					# Va a matchear todos los lienzos menos el vacio, es de tipo CANVAS. 
					when /^<->/ , /^<\|>/ , /^<\_>/ , /^<\s>/ , /^<\/>/ , /^<\\>/
						word = line[/^<.>/]
						line = line.partition(word).last
						@tokensList << Token.new(:CANVAS, word[1], [lineNum, colNum])
						colNum += word.size	

					# Va a matchear con #(lienzo vacio), es de tipo CANVAS. 
					when /^#/ 
						word = line[/^#/]
						line = line.partition(word).last
						@tokensList << Token.new(:CANVAS, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear los &, es de tipo ET
					when /^&/
						word = line[/^&/]
						line = line.partition(word).last
						@tokensList << Token.new(:ET, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear los ~, es de tipo TILDE
					when /^~/
						word = line[/^~/]
						line = line.partition(word).last
						@tokensList << Token.new(:TILDE, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear LOS <=, es de tipo GREATER OR  EQUAL. 
					when /^>=/
						word = line[/^>=/]
						line = line.partition(word).last
						@tokensList << Token.new(:GREATER_OR_EQUAL, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear LOS <=, es de tipo LESS OR EQUAL. 
					when /^<=/
						word = line[/^<=/]
						line = line.partition(word).last
						@tokensList << Token.new(:LESS_OR_EQUAL, word, [lineNum, colNum])
						colNum += word.size	
					
					# Va a matchear LOS >, es de tipo GREATER THAN.
					when /^>/
						word = line[/^>/]
						line = line.partition(word).last
						@tokensList << Token.new(:GREATER_THAN, word, [lineNum, colNum])
						colNum += word.size			

					# Va a matchear LOS <, es de tipo LESS THAN. 
					when /^</
						word = line[/^</]
						line = line.partition(word).last
						@tokensList << Token.new(:LESS_THAN, word, [lineNum, colNum])
						colNum += word.size		

					# Va a matchear todos =, es de tipo NOT EQUAL. 
					when /^\/=/
						word = line[/^\/=/]
						line = line.partition(word).last
						@tokensList << Token.new(:NOT_EQUAL, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos =, es de tipo EQUALS. 
					when /^=/
						word = line[/^=/]
						line = line.partition(word).last
						@tokensList << Token.new(:EQUALS, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos :, es de tipo COLON. 
					when /^:/
						word = line[/^:/]
						line = line.partition(word).last
						@tokensList << Token.new(:COLON, word, [lineNum, colNum])
						colNum += word.size		


					# Va a matchear todos ;, es de tipo PERCENT. 
					when /^[%]/
						word = line[/^[%]/]
						line = line.partition(word).last
						@tokensList << Token.new(:PERCENT, word, [lineNum, colNum])
						colNum += word.size	

					# Va a matchear todos +, es de tipo PLUS. 
					when /^[+]/
						word = line[/^[+]/]
						line = line.partition(word).last
						@tokensList << Token.new(:PLUS, word, [lineNum, colNum])
						colNum += word.size

					# Va a matchear todos +, es de tipo PLUS. 
					when /^[*]/
						word = line[/^[*]/]
						line = line.partition(word).last
						@tokensList << Token.new(:MULTIPLY, word, [lineNum, colNum])
						colNum += word.size									

					# Va a matchear todos /, es de tipo DIVISION. 
					when /^[\/]/
						word = line[/^[\/]/]
						line = line.partition(word).last
						@tokensList << Token.new(:DIVISION, word, [lineNum, colNum])
						colNum += word.size

					# y esto es para todo lo que no sean palabras validas (letras en este ejemplo).
					else
						word = line[/^./]
						line = line.partition(word).last
						@errList << Token.new("", word, [lineNum, colNum])
						colNum += word.size
					end
				end	
			end
		end
		# Si hubo algun caracter invalido, se imprime y se borra el arreglo de tokens validos.
		if errComm == true 
			puts "ERROR: Comment section opened but not closed at line: " \
						"#{commline}, column: #{commcol} \n"
		else 

			if (@errList.length > 0)
				@tokensList.drop(@tokensList.length)
				for err in @errList
					puts "ERROR: Unexpected character: '#{err.symbol}' at line: " \
								"#{err.position[0]}, column: #{err.position[1]} \n"
				end
			# Si todos los caracteres son validos, se imprimen los tokens.
			else
				for tok in @tokensList
					puts "token #{tok.id} value (#{tok.symbol}) at line: #{tok.position[0]}," \
									" column: #{tok.position[1]} \n"
				end
			end
		end	
	end

	def next_token
		if ((tok = @tokensList.shift) != nil)
			@tokensAux << tok
			return tok.idAndValue
		else
			return nil
		end
	end
end














