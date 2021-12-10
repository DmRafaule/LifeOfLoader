extends Node

var pp = preload("res://scenes/Popup.tscn")
var v_l = preload("res://scenes/characters/visitor_low.tscn")
var v_m = preload("res://scenes/characters/visitor_medium.tscn")
var v_t = preload("res://scenes/characters/visitor_tall.tscn")

var current_hour = 12
var current_day = 1
var month =	["","work","work","free","free",
			"work","work","free","free",
			"work","work","free","free",
			"work","work","free","free",
			"work","work","free","free",
			"work","work","free","free",
			"work","work","free","free",
			"work","work",
			]
var dialogs = [] # dialogs data
var current_dialog_win = 0 # current dialog context
var isEndPhrase   = false # is resources free and can prog call createDialogWin
var isDialogStart = false # this is exist only for one reason do not play animation for apearing UI if it is just random phase
var cash = 0 # All cash collected throu the game
var lethalMistakes = 0 # Counter for lethal(end game)
var setCharacters = [] # who is acting in this day
