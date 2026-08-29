#!/usr/bin/env bash
set -euo pipefail

TARGET_WIN=$(niri msg --json focused-window 2>/dev/null || echo "{}")
TARGET_APP_ID=$(echo "$TARGET_WIN" | jq -r '.app_id // ""' | tr '[:upper:]' '[:lower:]')
TARGET_TITLE=$(echo "$TARGET_WIN" | jq -r '.title // ""' | tr '[:upper:]' '[:lower:]')

STATE_DIR="$HOME/.local/state/emoji-picker"
CACHE_DIR="$HOME/.cache/emoji-picker"
mkdir -p "$STATE_DIR" "$CACHE_DIR"

HISTORY_FILE="$STATE_DIR/history.tsv"
touch "$HISTORY_FILE"

FONT="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-11}"

get_base_emojis() {
    cat << 'EOF'
😭 :sob: loudly crying face sad tears upset weeping
💀 :skull: skull dead deadass skeleton
🔥 :fire: flame lit hot fire blaze
👍 :thumbsup: thumbs up approve like yes +1
👀 :eyes: looking eyes sneak peek see watch
😂 :joy: face with tears of joy laughing lol haha
🙏 :pray: folded hands please thank you namaste prayer
🗿 :moyai: moai chad stone face easter island sigma
😅 :sweat_smile: grinning face with sweat nervous awkward phew
✨ :sparkles: sparkles shiny magic star clean
🥹 :pleading_face: :face_holding_back_tears: emotional crying cute
🤷 :shrug: person shrugging idk whatever no idea
🫡 :salute: saluting face yes sir respect soldier
❤️ :heart: red heart love romance
🥀 :wilted_flower: wilted rose dead flower sorrow
💯 :100: hundred points score perfect full real
🎉 :tada: party popper celebration congrats celebrate
😳 :flushed: flushed wide eyes shocked stunned embarrassed
🇨🇾 :flag_cy: flag cyprus cypriot
🇵🇱 :flag_pl: flag poland polish
🏳️‍⚧️ :transgender_flag: trans transgender pride flag
1️⃣ :one: keycap 1 number one first
🥁 :drum: drum music percussion beat
🙊 :speak_no_evil: speak no evil monkey quiet hush
😏 :smirk: smirking face suggestive playful sly
💜 :purple_heart: purple heart love
🩷 :pink_heart: pink heart cute sweet
💛 :yellow_heart: yellow heart friendship
💖 :sparkling_heart: sparkling heart love shiny
🏎️ :racing_car: f1 formula1 race car stem racing fast speed
🦦 :otter: otter cute animal water
😡 :rage: pouting face angry mad furious red
😱 :scream: face screaming in fear shocked terrified
⭐ :star: gold star favorite rating
😔 :pensive: pensive sad face depressed down
🤯 :exploding_head: mind blown shocked disbelief
🫂 :people_hugging: hug friends care embrace comfort
🙈 :see_no_evil: see no evil monkey shy peek
🙉 :hear_no_evil: hear no evil monkey deaf
🤔 :thinking: thinking face hmm consider ponder
🤨 :raised_eyebrow: face with raised eyebrow sus suspect skeptical
🤣 :rofl: rolling on the floor laughing lmao dead
🥰 :smiling_face_with_3_hearts: in love cute happy affectionate
😍 :heart_eyes: heart eyes love crush adore
😎 :sunglasses: cool sunglasses awesome stylish
🥳 :partying_face: party celebration horn hat fun
😴 :sleeping: sleeping zzz tired sleepy nap
🤢 :nauseated_face: sick gross disgusted green
🤮 :vomiting: puking vomiting gross barf
🤡 :clown: clown fool silly circus
💩 :poop: pile of poo crap shit funny
💪 :muscle: flex bicep strong strength gym workout
🤝 :handshake: handshake deal agreement partnership
✌️ :v: victory peace hand two
🖕 :middle_finger: middle finger offensive rude
👏 :clap: clapping hands applause bravo good job
👋 :wave: waving hand hello goodbye hi
🤌 :pinched_fingers: pinched fingers italian chef kiss what do you want
🚀 :rocket: rocket launch moon fast blast off space
💡 :bulb: light bulb idea inspiration innovation insight
📌 :pushpin: pushpin pin important notice memo
✅ :white_check_mark: check mark done pass complete yes
❌ :x: cross mark wrong fail cancel no
⚠️ :warning: warning alert caution danger problem
⛔ :no_entry: no entry forbidden stop banned
🔒 :lock: locked secure private secret closed
🔓 :unlock: unlocked open accessible
☕ :coffee: coffee hot drink tea espresso cafe
🍺 :beer: beer drink celebration pub cheers alcohol
🍕 :pizza: pizza food fast food cheese slice
🍔 :hamburger: burger food cheeseburger fast food
🍟 :fries: french fries food potato mcdonalds
🍿 :popcorn: popcorn movie snack cinema
💻 :computer: laptop tech coding pc computer developer
📱 :phone: mobile phone smartphone iphone android call
🎧 :headphones: headphones music audio listening podcast
🎮 :video_game: video game controller gaming playstation xbox
📚 :books: books study revision reading library learn
📝 :memo: memo note write document exam pencil
🗑️ :wastebasket: trash can delete bin remove garbage
🔧 :wrench: wrench tool fix settings repair mechanics
🔨 :hammer: hammer build fix tool construct
⚡ :zap: high voltage lightning electricity fast thunder
🌈 :rainbow: rainbow pride colors sky nature
☀️ :sunny: sun bright sunny day weather summer
🌙 :crescent_moon: crescent moon night sleep evening
🌧️ :cloud_rain: rain cloud rainy weather precipitation
❄️ :snowflake: snowflake snow cold winter freeze nix
✔️ :heavy_check_mark: check ok correct
✖️ :heavy_multiplication_x: cross cancel multiply
❓ :question: question mark help confused query
❗ :exclamation: exclamation mark alert warning attention
🏆 :trophy: trophy winner first place champion prize
🥇 :first_place_medal: 1st place gold medal winner
🥈 :second_place_medal: 2nd place silver medal
🥉 :third_place_medal: 3rd place bronze medal
👑 :crown: crown king queen royal leader majesty
💰 :moneybag: money bag cash rich wealth dollar
🎯 :dart: direct hit target bullseye goal accurate
🔥 :flame: fire hot burn
👻 :ghost: ghost spooky halloween boo spirit
👽 :alien: alien space ufo extraterrestrial
🤖 :robot: robot bot tech ai automation
🐱 :cat: cat cute pet kitten meow
🐶 :dog: dog cute pet puppy woof
🦊 :fox: fox cute animal wild red
🐼 :panda_face: panda bear cute animal bamboo
🐻 :bear: bear animal forest wild
🐨 :koala: koala cute animal australia
🦁 :lion: lion king wild cat jungle
🐯 :tiger: tiger wild cat stripes predator
🐲 :dragon_face: dragon mythical fantasy beast
🐍 :snake: snake python reptile coding danger
🐛 :bug: bug insect error debug caterpillar
🕷️ :spider: spider web creepy arachnid insect
🌹 :rose: rose flower love red romantic
🌻 :sunflower: sunflower yellow bright summer flower
🌳 :deciduous_tree: tree nature green forest plant
🌵 :cactus: cactus desert plant spike succulent
🌎 :earth_americas: globe earth world planet map
🌕 :full_moon: full moon space night sky
🌟 :star2: glowing star shine sparkle bright
🎈 :balloon: balloon party birthday celebration air
🎁 :gift: wrapped present gift birthday surprise
🔔 :bell: bell notification alert ring reminder
📣 :mega: megaphone announcement loud shout broadcast
🎤 :microphone: mic sing podcast audio vocal
📻 :radio: radio music broadcast tune sound
📷 :camera: camera photo picture capture snap
📹 :video_camera: video camera movie recording cam
📽️ :film_projector: cinema film movie projector theatre
📺 :tv: television screen monitor display broadcast
⌛ :hourglass: hourglass time loading wait running
⏰ :alarm_clock: alarm clock time wake morning
🧭 :compass: compass direction navigate explore orient
🔑 :key: key password unlock security access
🛡️ :shield: shield defense protect privacy armor
⚔️ :crossed_swords: swords battle fight pvp combat
🏹 :bow_and_arrow: bow archery target shoot arrow
💣 :bomb: bomb explosion danger blast explosive
💎 :gem: gem jewel diamond luxury precious crystal
🔮 :crystal_ball: crystal ball fortune magic psychic future
🎲 :game_die: dice random chance board game roll
🎭 :performing_arts: drama theater acting masks stage
🎨 :art: artist palette painting draw design creative
🧵 :thread: thread needle sew stitching tailor
🧶 :yarn: yarn knit crochet wool craft
🛒 :shopping_cart: cart store buy order purchase market
🛍️ :shopping_bags: shopping bags retail store purchase fashion
📦 :package: package delivery box shipping parcel amazon
✉️ :email: envelope message letter contact mail postal
📥 :inbox_tray: inbox incoming receive mail tray
📤 :outbox_tray: outbox send mail message dispatch
📁 :file_folder: folder directory files organizer storage
📄 :page_facing_up: document page paper text article
📊 :bar_chart: bar chart graph stats analytics finance
📋 :clipboard: clipboard paste copy notes board
📅 :calendar: calendar date schedule agenda month
🔖 :bookmark: bookmark save favorite tag label
🔗 :link: hyperlink connect attach url website
⛓️ :chains: chains bind metal strong connection
🧲 :magnet: magnet attract pull physics force
🔋 :battery: battery power charge energy level
🔌 :electric_plug: electric plug power socket connect charging
🕯️ :candle: candle flame light wax burn
🪞 :mirror: mirror reflection glass look silver
🚪 :door: door entrance exit room open
🛏️ :bed: bed sleep rest hotel bedroom
🪑 :chair: chair sit seat furniture desk
🛋️ :couch_and_lamp: sofa living room lounge relax couch
🚽 :toilet: restroom bathroom washroom wc flush
🚿 :shower: shower bath water clean hygiene
🧼 :soap: soap clean wash hygiene bubbles
🧹 :broom: broom sweep clean tidy dust
🧺 :basket: basket storage carry picnic laundry
🪣 :bucket: bucket water container wash mop
🪜 :ladder: ladder climb step height ascent
🧰 :toolbox: toolbox kit maintenance repair tools
⚙️ :gear: gear setting config mechanism cog engine
⚓ :anchor: anchor boat nautical secure harbor
🪝 :hook: fishing hook catch grab pirate
🚩 :triangular_flag_on_post: flag marker checkpoint post red
🏁 :checkered_flag: checkered flag race finish winner victory
🔭 :telescope: telescope astronomy stars look space galaxy
🔬 :microscope: microscope science research laboratory biology
🧪 :test_tube: test tube chemistry science experiment potion
💉 :syringe: syringe vaccine injection medical doctor blood
💊 :pill: pill capsule medicine health pharmacy drug
🩺 :stethoscope: stethoscope doctor medical health clinic heart
🌡️ :thermometer: thermometer temperature fever heat weather
🩹 :adhesive_bandage: bandage bandaid heal wound injury first aid
🩼 :crutch: crutch injury support walk broken leg
🧑‍🦽 :manual_wheelchair: wheelchair accessible disability mobility
🧬 :dna: dna genetics biology code evolution gene
🦠 :microbe: microbe bacteria virus biology germ covid
🦷 :tooth: tooth dental dentist clean molar smile
🦴 :bone: bone skeleton dog treat anatomy
🧠 :brain: brain mind intellect think smart psychology
👁️ :eye: single eye look watch see vision
👂 :ear: ear hear listen sound audio
👃 :nose: nose smell sniff scent breath
👄 :lips: lips mouth kiss red lipstick beauty
👅 :tongue: tongue taste lick tease silly
🦶 :foot: foot step walk kick barefoot
🦵 :leg: leg limb kick walk thigh
🖐️ :raised_hand: hand stop high five palm five
🫠 :melting_face: melting sarcasm hot heat disappearing
🫢 :face_with_open_eyes_and_hand_over_mouth: gasping shocked oops
🫣 :peeking_eye: peek scared look shy
🥱 :yawning_face: yawn tired bored sleepy
🤐 :zipper_mouth_face: shut up secret quiet silent
🤫 :shushing_face: shh quiet secret silence
🤭 :giggling: giggle teehee oops cute laugh
🤗 :hugging_face: hug friendly warm welcome
🙄 :face_with_rolling_eyes: eye roll whatever annoyed
😬 :grimacing: grimace yikes awkward tense
🤥 :lying_face: pinocchio lie liar fake
😌 :relieved: calm relaxed peaceful safe
🤤 :drooling_face: drool delicious hungry tasty
🤧 :sneezing_face: sneeze tissue sick cold allergy
🥶 :cold_face: freezing freezing cold blue frost
🥵 :hot_face: boiling hot sweating red summer
😵 :dizzy_face: dizzy dead unconscious knocked out
🤠 :cowboy_hat_face: cowboy yeehaw wild west hat
🥸 :disguised_face: disguise glasses moustache incognito
😈 :smiling_imp: devil naughty horn purple evil
👿 :imp: angry devil angry purple demon
☠️ :skull_and_crossbones: poison danger toxic pirate
👹 :ogre: japanese monster red ogre mask
👺 :goblin: goblin long nose red mask
👾 :space_invader: arcade pixel video game monster
EOF
}

get_sorted_emojis() {
    if [ -s "$HISTORY_FILE" ]; then
        local FREQ_LIST
        FREQ_LIST=$(awk -F'\t' '{count[$1]++} END {for (e in count) print count[e] "\t" e}' "$HISTORY_FILE" | sort -nr | cut -f2-)

        {
            while IFS= read -r emoji_line; do
                [ -n "$emoji_line" ] && echo "$emoji_line"
            done <<< "$FREQ_LIST"
            get_base_emojis
        } | awk '!seen[$1]++'
    else
        get_base_emojis
    fi
}

MENU_LIST=$(get_sorted_emojis)

SELECTED=$(echo "$MENU_LIST" | fuzzel --dmenu \
    --minimal-lines \
    --font="$FONT:size=$FONT_SIZE" \
    --prompt="Emoji: " \
    --background-color=1e1e2eff \
    --text-color=cdd6f4ff \
    --input-color=cdd6f4ff \
    --selection-color=585b70ff \
    --selection-text-color=cdd6f4ff \
    --width=45 \
    --lines=12 \
    --horizontal-pad=12 \
    --border-radius=10 || true)

[ -z "$SELECTED" ] && exit 0

EMOJI="${SELECTED%% *}"
[ -z "$EMOJI" ] && exit 0

echo -e "$SELECTED\t$(date +%s)" >> "$HISTORY_FILE"

PREV_CLIP=$(wl-paste -n 2>/dev/null || true)
echo -n "$EMOJI" | wl-copy

sleep 0.05

# If the target is a terminal, use Ctrl+Shift+V; otherwise, use standard Ctrl+V
if [[ "$TARGET_APP_ID" =~ (ghostty|kitty|foot|alacritty|wezterm|xterm|terminal|term) ]] || [[ "$TARGET_TITLE" =~ (ghostty|terminal|alacritty) ]]; then
    wtype -M ctrl -M shift -k v -m shift -m ctrl
else
    wtype -M ctrl -k v -m ctrl
fi

# Restore previous clipboard contents
(
    sleep 0.08
    if [ -n "$PREV_CLIP" ]; then
        echo -n "$PREV_CLIP" | wl-copy
    else
        wl-copy --clear 2>/dev/null || true
    fi
) & disown
