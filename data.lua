local defaultIntroEventBlacklist = {
	"asks"
}

local liquids = {
	"water",
	"milk",
	"orange juice",
	"apple juice",
	"lemonade",
}

local person = {
	"tallest",
	"nearest",
	"shortest",
	"largest",
	"smallest",
	"youngest",
	"oldest",
}

local events = {
	asks = {
		text = "somebody asks you about what you're doing"
	},

	passes = {
		text = "somebody passes by you"
	},

	eyeContact = {
		text = "you make eye contact with a stranger",
	},

	stubToe = {
		text = "you stub your toe",
	},

	startConversation = {
		text = "somebody starts a conversation with you",
	},
}

local locations = {
	roof = {
		text = "the roof of any building"
	},

	elevator = {
		text = "an elevator"
	},
}

local actions = {
	drink = {
		text = "drink ",

		modifiers = {
			{
				name = "oz",
				suffix = " of",
				required = true,
				max = 24,
				min = 2,

				avoidDeterminer = true,
			},
			{
				name = "liquid",
				required = true,

				determinerPrefix = "of ",
			},
		},

		options = {
		    {
				name = "duration",
				prefix = "in ",
				max = 20,
				min = 3,
			},

			{
				name = "blank",
			},
		},
	},

	run = {
		text = "run ",

		options = {
		    {
				name = "duration",
				prefix = "for ",
				max = 7200,
				min = 1,
			},

			{ 
            	name = "event", 
				prefix = "until ",
				blacklist = {"asks"}
            },
		},
	},

	jump = {
		text = "jump ",
		avoidDeterminer = true,
		
		options = {
		    {
				name = "duration",
				prefix = "for ",
				max = 20,
				min = 1,
			},

			{ 
            	name = "event", 
				prefix = "until ",
            },
		},
	},

	clap = {
		text = "clap ",
		avoidDeterminer = true,

		options = {
		    {
				name = "duration",
				prefix = "for ",
				max = 300,
				min = 5,
			},

			{ 
            	name = "event", 
				prefix = "until ",
            },
		},
	},

	hum = {
		text = "hum ",
		avoidDeterminer = true,

		options = {
		    {
				name = "duration",
				prefix = "for ",
				max = 300,
				min = 5,
			},
		},
	},

	stare = {
		text = "stare at ",
		avoidDeterminer = true,

		modifiers = {
			{
				name = "person",
			},
			{
				name = "location",
			},
		},

		options = {
		    {
				name = "duration",
				prefix = "for ",
				max = 300,
				min = 5,
			},
		},
	}
}

local extensions = {
	["and"] = {
		text = " and then ",

		options = {
		    {
				name = "duration",
				prefix = "after ",
				max = 21600,
				min = 1,
			},

			{ 
            	name = "event", 
				prefix = "after ",
            },

			{ 
            	name = "blank", 
            },
		},
	},

	["then"] = {
		text = ". Then ",

		options = {
		    {
				name = "duration",
				prefix = "in ",
				max = 21600,
				min = 1,
			},

			{ 
            	name = "blank", 
            },
		},
	},

	["afterwardsIf"] = {
		text = ". Afterwards, if ",

		options = {
			{ 
            	name = "event", 
            },
		},
	},
}

local intros = {
	["in"] = {
		text = "In ",

		options = {
			{
				name = "duration",
				min = 1,
				max = 259200,
			},
		},
	},

	["while"] = {
		text = "While ",

		options = {
			{
				name = "event",
				prefix = "",
				blacklist = defaultIntroEventBlacklist,
			},
		},
	},

	["when"] = {
		text = "When ",

		options = {
			{
				name = "location",
				prefix = "at ",
				blacklist = {},
			},
			{
				name = "event",
				prefix = "",
				blacklist = defaultIntroEventBlacklist,
			},
		},
	},

	["if"] = {
		text = "If ",

		options = {
			{
				name = "event",
				prefix = "",
				blacklist = defaultIntroEventBlacklist,
			},
		},
	},

	["take"] = {
		text = "Take a ",

		path = {},
	},
}

return {
	extensions = extensions,
	locations = locations,
	actions = actions,
	events = events,
	intros = intros,

	liquids = liquids,
}
