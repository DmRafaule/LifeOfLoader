extends Node

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
