class Parser

	# Define la precedencia de los tokens o expresiones en LANSCII.
	# El orden de precedencia fue basada en el siguiente link:
	# http://help.adobe.com/es_ES/AS2LCR/Flash_10.0/help.html?content=00000115.html
	prechigh

		nonassoc PRNTS

		nonassoc NEGATION
		nonassoc UMINUS
		left MULTIPLY DIVISION PERCENT
		left PLUS MINUS

		nonassoc TRANSPOSITION
		nonassoc ROTATION
		left ET TILDE

		nonassoc LESS_THAN GREATER_THAN LESS_OR_EQUAL GREATER_OR_EQUAL
		right NOT_EQUAL EQUALS

		left AND
		left OR

		right ASSIGN
		left SEMICOLON

	preclow

	# Lista de tokens validos de LANSCII (dadas por el lexer).
	token READ WRITE TRUE FALSE IDENTIFIER NUMBER AT EXCLAMATION_MARK
		TWO_POINTS LCURLY RCURLY RPARENTHESIS LPARENTHESIS RBRACKET 
		LBRACKET PIPE SEMICOLON QUESTION_MARK MINUS ROTATION TRANSPOSITION
		NEGATION OR AND CANVAS GREATER_OR_EQUAL LESS_OR_EQUAL GREATER_THAN
		LESS_THAN NOT_EQUAL EQUALS COLON PERCENT PLUS MULTIPLY DIVISION

	# Define la gramatica libre de contexto que reconoce a LANSCII.
	rule

	#################################
	# Estructura general de LANSCII #
	#################################

		# Simbolo inicial: define un programa en LANSCII e incorpora el alcance.
		S
		: LCURLY Decl PIPE Inst RCURLY
		| LCURLY Inst RCURLY
		;

		# Declaraciones: define las declaraciones en un entorno (alcance).
		Decl
		: Type ListI
		| Decl Type ListI
		;

		# Tipos: define los diferentes tipos de variables presentes en LANSCII.
		Type
		: AT
		| EXCLAMATION_MARK
		| PERCENT
		;

		# Lista de identificadores de variables: define el nombre de variables.
		ListI
		: Ident
		| ListI Ident
		;

		# Instrucciones: define las instrucciones validas asociadas a un programa
		# => o subprograma en LANSCII.
		Inst
		: Inst SEMICOLON Inst
		| Ident EQUALS Expr 	=ASSIGN
		| READ Ident
		| WRITE Expr
		| LPARENTHESIS Expr QUESTION_MARK Inst RPARENTHESIS
		| LPARENTHESIS Expr QUESTION_MARK Inst COLON Inst RPARENTHESIS
		| LBRACKET Expr PIPE Inst RBRACKET
		| LBRACKET Expr TWO_POINTS Expr PIPE Inst RBRACKET
		| LBRACKET Ident COLON Expr TWO_POINTS Expr PIPE Inst RBRACKET
		| S
		;

	##################################
	# Expresiones validas en LANSCII #
	##################################

		# Expresiones: define todas las expresiones recursivas en LANSCII.
		Expr
		: Term
		| Expr PLUS Expr
		| Expr MINUS Expr
		| Expr MULTIPLY Expr
		| Expr DIVISION Expr
		| Expr PERCENT Expr
		| MINUS Expr 	=UMINUS
		| LPARENTHESIS Expr RPARENTHESIS =PRNTS
		| Expr OR Expr
		| Expr AND Expr
		| Expr NEGATION
		| Expr LESS_THAN Expr
		| Expr GREATER_THAN Expr
		| Expr LESS_OR_EQUAL Expr
		| Expr GREATER_OR_EQUAL Expr
		| Expr EQUALS Expr
		| Expr NOT_EQUAL Expr
		| Expr TILDE Expr
		| Expr ET Expr
		| ROTATION Expr
		| Expr TRANSPOSITION
		;

		# Expresiones básicas: definen todas las expresiones hoja en LANSCII.
		Term
		: Bool
		| Num 
		| Lien
		| Ident
		;

		# Identificador: define el nombre de variables en LANSCII.
		Ident
		: IDENTIFIER
		;

		# Lienzos: define el tipo de los lienzos en LANSCII.
		Lien
		: CANVAS
		;

		# Numeros: define al tipo de los numeros en LANSCII.
		Num
		: NUMBER
		;

		# Booleanos: define al tipo de variables booleanas en LANSCII.
		Bool
		: TRUE
		| FALSE
		;
end

---- inner

require './lexer.rb'

def initialize(lexer)
	@lexer = lexer
end

def next_token
	@lexer.next_token
end

def parse
	do_parse
end