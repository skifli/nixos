{
  pkgsUnstable,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    services.xembed-sni-proxy.enable = true; # Workrave might need this

    home = {
      packages = [
        # Not yet in stable
        # TODO: When in stable or unstable re-add
        pkgsUnstable.breaktimer
      ];

      file.".config/BreakTimer/config.json".text = ''        {
        	"settings": {
        		"autoLaunch": true,
        		"breaksEnabled": true,
        		"trayTextEnabled": true,
        		"trayTextMode": "TIME_TO_NEXT_BREAK",
        		"notificationType": "POPUP",
        		"breakFrequencySeconds": 1680,
        		"breakLengthSeconds": 120,
        		"postponeLengthSeconds": 180,
        		"postponeLimit": 0,
        		"workingHoursEnabled": false,
        		"workingHoursMonday": {
        			"enabled": true,
        			"ranges": [
        				{
        					"fromMinutes": 540,
        					"toMinutes": 1080
        				}
        			]
        		},
        		"workingHoursTuesday": {
        			"enabled": true,
        			"ranges": [
        				{
        					"fromMinutes": 540,
        					"toMinutes": 1080
        				}
        			]
        		},
        		"workingHoursWednesday": {
        			"enabled": true,
        			"ranges": [
        				{
        					"fromMinutes": 540,
        					"toMinutes": 1080
        				}
        			]
        		},
        		"workingHoursThursday": {
        			"enabled": true,
        			"ranges": [
        				{
        					"fromMinutes": 540,
        					"toMinutes": 1080
        				}
        			]
        		},
        		"workingHoursFriday": {
        			"enabled": true,
        			"ranges": [
        				{
        					"fromMinutes": 540,
        					"toMinutes": 1080
        				}
        			]
        		},
        		"workingHoursSaturday": {
        			"enabled": false,
        			"ranges": [
        				{
        					"fromMinutes": 540,
        					"toMinutes": 1080
        				}
        			]
        		},
        		"workingHoursSunday": {
        			"enabled": false,
        			"ranges": [
        				{
        					"fromMinutes": 540,
        					"toMinutes": 1080
        				}
        			]
        		},
        		"idleResetEnabled": true,
        		"idleResetLengthSeconds": 300,
        		"idleResetNotification": true,
        		"soundType": "GONG",
        		"breakSoundVolume": 1,
        		"breakTitle": "Time for a break.",
        		"breakMessage": "Rest your eyes.\nStretch your legs.\nBreathe. Relax.",
        		"backgroundColor": "#16a085",
        		"textColor": "#ffffff",
        		"showBackdrop": true,
        		"backdropOpacity": 0.7,
        		"endBreakEnabled": true,
        		"skipBreakEnabled": false,
        		"postponeBreakEnabled": true,
        		"immediatelyStartBreaks": false
        	},
        	"appInitialized": true,
        	"settingsVersion": 2,
        	"disableEndTime": null
        }'';
    };
  };
}
