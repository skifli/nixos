# pins.nix
let
  containers = import ./containers.nix;
  spaces = import ./spaces.nix;

  # ---- Home Space Folders ----
  
  # Main folders in Home space
  artThouRight = {
    id = "e1111111-1111-4111-8111-111111111111";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1000;
  };

  yr11 = {
    id = "e2222222-2222-4222-8222-222222222222";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1100;
  };

  yr12 = {
    id = "e3333333-3333-4333-8333-333333333333";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1200;
  };

  yr13 = {
    id = "e4444444-4444-4444-8444-444444444444";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1300;
  };

  # Subfolders of artThouRight
  moonehSpend = {
    id = "f1111111-1111-4111-8111-111111111111";
    workspace = spaces.Home.id;
    folderParentId = artThouRight.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1001;
  };

  photosSource = {
    id = "f2222222-2222-4222-8222-222222222222";
    workspace = spaces.Home.id;
    folderParentId = artThouRight.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1002;
  };

  # Subfolders of yr11
  workExperienceY11 = {
    id = "f3333333-3333-4333-8333-333333333333";
    workspace = spaces.Home.id;
    folderParentId = yr11.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1101;
  };

  # Subfolders of yr12
  calcUSlayter = {
    id = "g1111111-1111-4111-8111-111111111111";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1201;
  };

  revisionResourcesY12 = {
    id = "g2222222-2222-4222-8222-222222222222";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1202;
  };

  baftaYgd = {
    id = "g3333333-3333-4333-8333-333333333333";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1203;
  };

  bio = {
    id = "g4444444-4444-4444-8444-444444444444";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1204;
  };

  competitions = {
    id = "g5555555-5555-4555-8555-555555555555";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1205;
  };

  incubators = {
    id = "g6666666-6666-4666-8666-666666666666";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1206;
  };

  programs = {
    id = "g7777777-7777-4777-8777-777777777777";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1207;
  };

  summerSchool = {
    id = "g8888888-8888-4888-8888-888888888888";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1208;
  };

  # Subfolder of competitions
  nasaSpaceApps = {
    id = "h1111111-1111-4111-8111-111111111111";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1209;
  };

  # Subfolders of yr13
  gsoc = {
    id = "h2222222-2222-4222-8222-222222222222";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1301;
  };

  mlh = {
    id = "h3333333-3333-4333-8333-333333333333";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1302;
  };

  outreachy = {
    id = "h4444444-4444-4444-8444-444444444444";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1303;
  };

  revisionResourcesY13 = {
    id = "h5555555-5555-4555-8555-555555555555";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1304;
  };

  # New folders for better organization
  ayoLevelResources = {
    id = "i1111111-1111-4111-8111-111111111111";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1400;
  };

  uknees = {
    id = "i2222222-2222-4222-8222-222222222222";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1500;
  };

  # Subfolders of uknees
  imperialStuff = {
    id = "j1111111-1111-4111-8111-111111111111";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1501;
  };

  courses = {
    id = "j2222222-2222-4222-8222-222222222222";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1502;
  };

  engineeringResources = {
    id = "j3333333-3333-4333-8333-333333333333";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1503;
  };

  postUknee = {
    id = "i3333333-3333-4333-8333-333333333333";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1600;
  };

  # Subfolders of postUknee
  undergraduate = {
    id = "j4444444-4444-4444-8444-444444444444";
    workspace = spaces.Home.id;
    folderParentId = postUknee.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1601;
  };

  postgraduate = {
    id = "j5555555-5555-4555-8555-555555555555";
    workspace = spaces.Home.id;
    folderParentId = postUknee.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1602;
  };

  # ---- Programming Space Folders ----
  
  # Moved from Home space per your request
  devIces = {
    id = "k1111111-1111-4111-8111-111111111111";
    workspace = spaces.Programming.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 3100;
  };

  nixOS = {
    id = "k2222222-2222-4222-8222-222222222222";
    workspace = spaces.Programming.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 3200;
  };

  pogRamming = {
    id = "k3333333-3333-4333-8333-333333333333";
    workspace = spaces.Programming.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 3300;
  };

  # RPI-specific folder in Programming space
  raspberryPi = {
    id = "k4444444-4444-4444-8444-444444444444";
    workspace = spaces.Programming.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 3400;
  };

in
{
  # ---- Essential pins (Home container) ----

  Spotify = {
    id = "a1111111-1111-4111-8111-111111111111";
    url = "https://open.spotify.com/playlist/37i9dQZEVXcXHWVVT0lfDq";
    container = containers.Home.id;
    isEssential = true;
    position = 100;
  };

  ChatGPT = {
    id = "b2222222-2222-4222-8222-222222222222";
    url = "https://chatgpt.com";
    container = containers.Home.id;
    isEssential = true;
    position = 101;
  };

  Gemini = {
    id = "d4444444-4444-4444-8444-444444444444";
    url = "https://gemini.google.com/u/1/app";
    container = containers.Home.id;
    isEssential = true;
    position = 103;
  };

  # ---- Folder Structure Definitions ----

  # Home Space Folders
  "Art-thou-right" = artThouRight;
  "Y11" = yr11;
  "Y12" = yr12;
  "Y13" = yr13;
  "Ayo Level Resources" = ayoLevelResources;
  "U-knees" = uknees;
  "Post Uknee" = postUknee;

  # Programming Space Folders
  "Dev-Ices" = devIces;
  "nixOS" = nixOS;
  "Pog-ramming" = pogRamming;
  "Raspberry Pi" = raspberryPi;

  # ---- Pins in Home Space ----

  # Essentials pins (already defined above)

  # Art-thou-right pins
  "sfG MentorNet" = {
    id = "m1111111-1111-4111-8111-111111111111";
    url = "https://smallpeicetrust.sfgmentornet.com/auth/account/login";
    workspace = spaces.Home.id;
    folderParentId = artThouRight.id;
    position = 1003;
  };

  "Smallpeice Events Calendar" = {
    id = "m2222222-2222-4222-8222-222222222222";
    url = "https://www.smallpeicetrust.org.uk/events-calendar/?course_type=110";
    workspace = spaces.Home.id;
    folderParentId = artThouRight.id;
    position = 1004;
  };

  # Mooneh Spend subfolder pins
  "AliExpress Phone Stands" = {
    id = "n1111111-1111-4111-8111-111111111111";
    url = "https://www.aliexpress.com/w/wholesale-phone-stand.html";
    workspace = spaces.Home.id;
    folderParentId = moonehSpend.id;
    position = 1010;
  };

  "UGREEN Power Bank" = {
    id = "n2222222-2222-4222-8222-222222222222";
    url = "https://www.amazon.co.uk/UGREEN-20000mAh-Charging-Portable-Compatible/dp/B0DSPVDYQ9";
    workspace = spaces.Home.id;
    folderParentId = moonehSpend.id;
    position = 1011;
  };

  "Magsafe Table Mount" = {
    id = "n3333333-3333-4333-8333-333333333333";
    url = "https://www.amazon.co.uk/s?k=magsafe+table+mount";
    workspace = spaces.Home.id;
    folderParentId = moonehSpend.id;
    position = 1012;
  };

  "AliExpress Monitor Arms" = {
    id = "n4444444-4444-4444-8444-444444444444";
    url = "https://www.aliexpress.com/w/wholesale-monitor-arms.html";
    workspace = spaces.Home.id;
    folderParentId = moonehSpend.id;
    position = 1013;
  };

  "Magsafe Clamp" = {
    id = "n5555555-5555-4555-8555-555555555555";
    url = "https://www.aliexpress.com/w/wholesale-magsafe-tabl-clamp.html";
    workspace = spaces.Home.id;
    folderParentId = moonehSpend.id;
    position = 1014;
  };

  # Photos Source subfolder pins
  "Arkwright Event Photos" = {
    id = "o1111111-1111-4111-8111-111111111111";
    url = "https://gallery.squireandsquire.co.uk/-arkwrightengineeringscholarshipsnetworkingeventsouth/gallery";
    workspace = spaces.Home.id;
    folderParentId = photosSource.id;
    position = 1020;
  };

  "Arkwright General Photos" = {
    id = "o2222222-2222-4222-8222-222222222222";
    url = "https://gallery.squireandsquire.co.uk/-arkwrightengineeringeventsouthgeneralphotography/store";
    workspace = spaces.Home.id;
    folderParentId = photosSource.id;
    position = 1021;
  };

  # Y11 pins
  "AI Alignment" = {
    id = "p1111111-1111-4111-8111-111111111111";
    url = "https://bluedot.org/courses/alignment?from_site=aisf";
    workspace = spaces.Home.id;
    folderParentId = yr11.id;
    position = 1110;
  };

  "GCSE Log" = {
    id = "p2222222-2222-4222-8222-222222222222";
    url = "https://gcselog.com/";
    workspace = spaces.Home.id;
    folderParentId = yr11.id;
    position = 1111;
  };

  "Telford Engineering Scholarship" = {
    id = "p3333333-3333-4333-8333-333333333333";
    url = "https://rbt.org.uk/grants/telford-engineering-scholarship/";
    workspace = spaces.Home.id;
    folderParentId = yr11.id;
    position = 1112;
  };

  # Y12 pins
  "OneHive" = {
    id = "q1111111-1111-4111-8111-111111111111";
    url = "https://tutorhive.co.uk/onehive/app/application/index";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1210;
  };

  "Add Timestamp to Photo" = {
    id = "q2222222-2222-4222-8222-222222222222";
    url = "https://imageonline.co/add-date-timestamp-to-photo.php";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1211;
  };

  "SIMS ID" = {
    id = "q3333333-3333-4333-8333-333333333333";
    url = "https://sts.sims.co.uk/login?signin=70f83f94901d3f0c32f7774917d4b242";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1212;
  };

  "OneDrive Enterprise" = {
    id = "q4444444-4444-4444-8444-444444444444";
    url = "https://stolavesgrammarschool-my.sharepoint.com/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1213;
  };

  "MATLAB" = {
    id = "q5555555-5555-4555-8555-555555555555";
    url = "https://matlab.mathworks.com/";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1214;
  };

  "Caius 12" = {
    id = "q6666666-6666-4666-8666-666666666666";
    url = "https://www.cai.cam.ac.uk/access-outreach/schemes-and-events/caius-12";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1215;
  };

  "Sutton Trust US" = {
    id = "q7777777-7777-4777-8777-777777777777";
    url = "https://us.suttontrust.com/how-to-apply/";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1216;
  };

  "AI Exam Tutor" = {
    id = "q8888888-8888-4888-8888-888888888888";
    url = "https://ai-exam-tutor.web.app/loginSignUp.html";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1217;
  };

  "RAF Benson" = {
    id = "q9999999-9999-4999-8999-999999999999";
    url = "https://www.raf.mod.uk/our-organisation/stations/raf-benson/contact-us/";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1218;
  };

  "Smallpeice Calendar" = {
    id = "r1111111-1111-4111-8111-111111111111";
    url = "https://www.smallpeicetrust.org.uk/events-calendar/";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1219;
  };

  "Pathway CTM" = {
    id = "r2222222-2222-4222-8222-222222222222";
    url = "https://pathwayctm.com/welcome/";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1220;
  };

  "Medly AI" = {
    id = "r3333333-3333-4333-8333-333333333333";
    url = "https://medlyai.com/uk";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1221;
  };

  "Bright Network" = {
    id = "r4444444-4444-4444-8444-444444444444";
    url = "https://www.brightnetwork.co.uk/login/?next=/dashboard/";
    workspace = spaces.Home.id;
    folderParentId = yr12.id;
    position = 1222;
  };

  # Calc-U-SLAYTER subfolder
  "Prizm Programming Portal" = {
    id = "s1111111-1111-4111-8111-111111111111";
    url = "https://prizm.cemetech.net/Prizm_Programming_Portal/";
    workspace = spaces.Home.id;
    folderParentId = calcUSlayter.id;
    position = 1230;
  };

  # Revision Resources subfolder (Y12)
  "Daniyaals Guides" = {
    id = "s2222222-2222-4222-8222-222222222222";
    url = "https://daniyaalanawar.notion.site/Daniyaal-s-Guides-1da27b56e1808094b867dfb6723f314c";
    workspace = spaces.Home.id;
    folderParentId = revisionResourcesY12.id;
    position = 1240;
  };

  # BAFTA YGD subfolder
  "Young Game Designers" = {
    id = "s3333333-3333-4333-8333-333333333333";
    url = "https://www.bafta.org/programmes/young-game-designer/";
    workspace = spaces.Home.id;
    folderParentId = baftaYgd.id;
    position = 1250;
  };

  "BAFTA YGD Terms" = {
    id = "s4444444-4444-4444-8444-444444444444";
    url = "https://www.bafta.org/wp-content/uploads/2024/11/2025-BAFTA-YGD-TCs-FINAL.pdf";
    workspace = spaces.Home.id;
    folderParentId = baftaYgd.id;
    position = 1251;
  };

  # BIO subfolder
  "BIO Solutions" = {
    id = "t1111111-1111-4111-8111-111111111111";
    url = "https://github.com/tmncollins/BIO-Solutions";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    position = 1260;
  };

  "Competitive Programming Guide" = {
    id = "t2222222-2222-4222-8222-222222222222";
    url = "https://www.geeksforgeeks.org/dsa/competitive-programming-a-complete-guide/";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    position = 1261;
  };

  "BIO Helper" = {
    id = "t3333333-3333-4333-8333-333333333333";
    url = "https://www.britishinformatics.org/bio1?problem=Short+Fuse";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    position = 1262;
  };

  "BIO 2025" = {
    id = "t4444444-4444-4444-8444-444444444444";
    url = "https://www.olympiad.org.uk/2025/index.html";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    position = 1263;
  };

  # Competitions subfolder
  "Technical AI Safety" = {
    id = "u1111111-1111-4111-8111-111111111111";
    url = "https://web.miniextensions.com/9YX1i46qewCv5m17v8rl";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    position = 1270;
  };

  "Codeheat" = {
    id = "u2222222-2222-4222-8222-222222222222";
    url = "https://codeheat.org/";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    position = 1271;
  };

  "Hacktoberfest" = {
    id = "u3333333-3333-4333-8333-333333333333";
    url = "https://hacktoberfest.com/";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    position = 1272;
  };

  "Summer of Nix" = {
    id = "u4444444-4444-4444-8444-444444444444";
    url = "https://github.com/ngi-nix/summer-of-nix";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    position = 1273;
  };

  "BeyondAI" = {
    id = "u5555555-5555-4555-8555-555555555555";
    url = "https://thinkingbeyond.education/beyondai/";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    position = 1274;
  };

  # NASA Space Apps subfolder
  "NASA Space Apps FAQ" = {
    id = "v1111111-1111-4111-8111-111111111111";
    url = "https://www.spaceappschallenge.org/resources/-faq/";
    workspace = spaces.Home.id;
    folderParentId = nasaSpaceApps.id;
    position = 1280;
  };

  "NASA Space Apps London" = {
    id = "v2222222-2222-4222-8222-222222222222";
    url = "https://www.spaceappschallenge.org/nasa-space-apps-2024/2024-local-events/london/?tab=details";
    workspace = spaces.Home.id;
    folderParentId = nasaSpaceApps.id;
    position = 1281;
  };

  # Incubators subfolder
  "Leaf" = {
    id = "w1111111-1111-4111-8111-111111111111";
    url = "https://leaf.courses/";
    workspace = spaces.Home.id;
    folderParentId = incubators.id;
    position = 1290;
  };

  "Young Asians" = {
    id = "w2222222-2222-4222-8222-222222222222";
    url = "https://www.youngasians.org/";
    workspace = spaces.Home.id;
    folderParentId = incubators.id;
    position = 1291;
  };

  "Jumpstart" = {
    id = "w3333333-3333-4333-8333-333333333333";
    url = "https://www.jumpstart-uk.com/";
    workspace = spaces.Home.id;
    folderParentId = incubators.id;
    position = 1292;
  };

  "Non-Trivial" = {
    id = "w4444444-4444-4444-8444-444444444444";
    url = "https://www.non-trivial.org/";
    workspace = spaces.Home.id;
    folderParentId = incubators.id;
    position = 1293;
  };

  "Kickstart" = {
    id = "w5555555-5555-4555-8555-555555555555";
    url = "https://kickstartglobal.com/#welcome";
    workspace = spaces.Home.id;
    folderParentId = incubators.id;
    position = 1294;
  };

  # Programs subfolder
  "STEM SMART" = {
    id = "x1111111-1111-4111-8111-111111111111";
    url = "https://www.undergraduate.study.cam.ac.uk/stem-smart";
    workspace = spaces.Home.id;
    folderParentId = programs.id;
    position = 1300;
  };

  "In2STEM" = {
    id = "x2222222-2222-4222-8222-222222222222";
    url = "https://in2scienceuk.org/our-programmes/in2stem/apply/";
    workspace = spaces.Home.id;
    folderParentId = programs.id;
    position = 1301;
  };

  "COMPOS" = {
    id = "x3333333-3333-4333-8333-333333333333";
    url = "https://compos.web.ox.ac.uk/home";
    workspace = spaces.Home.id;
    folderParentId = programs.id;
    position = 1302;
  };

  "Quantum Club" = {
    id = "x4444444-4444-4444-8444-444444444444";
    url = "https://www.physics.ox.ac.uk/engage/schools/secondary-schools/projects-and-mentoring/quantum-club";
    workspace = spaces.Home.id;
    folderParentId = programs.id;
    position = 1303;
  };

  "Future Leaders" = {
    id = "x5555555-5555-4555-8555-555555555555";
    url = "https://www.futureleaders.uk/application";
    workspace = spaces.Home.id;
    folderParentId = programs.id;
    position = 1304;
  };

  "KDE Mentorship" = {
    id = "x6666666-6666-4666-8666-666666666666";
    url = "https://mentorship.kde.org/";
    workspace = spaces.Home.id;
    folderParentId = programs.id;
    position = 1305;
  };

  # Summer School subfolder
  "KCL Summer School" = {
    id = "y1111111-1111-4111-8111-111111111111";
    url = "https://www.kcl.ac.uk/summer/summer-on-campus/pre-university-summer-school";
    workspace = spaces.Home.id;
    folderParentId = summerSchool.id;
    position = 1310;
  };

  # Y13 pins
  "Microsoft Account" = {
    id = "z1111111-1111-4111-8111-111111111111";
    url = "https://myaccount.microsoft.com/?ref=MeControl";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1315;
  };

  "Integral" = {
    id = "z2222222-2222-4222-8222-222222222222";
    url = "https://my.integralmaths.org/my/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1316;
  };

  "ICSC" = {
    id = "z3333333-3333-4333-8333-333333333333";
    url = "https://icscompetition.org/en/index";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1317;
  };

  "UK Cyber Team" = {
    id = "z4444444-4444-4444-8444-444444444444";
    url = "https://ukcyberteam.sans.org/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1318;
  };

  "AMSP Event" = {
    id = "z5555555-5555-4555-8555-555555555555";
    url = "https://amsp.org.uk/event/4d462908-22e5-48f4-abea-b919d52eaa20/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1319;
  };

  "Generation Google" = {
    id = "aa1111111-1111-4111-8111-111111111111";
    url = "https://www.iie.org/programs/generationgoogle/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1320;
  };

  "ThinkingBeyond" = {
    id = "aa2222222-2222-4222-8222-222222222222";
    url = "https://thinkingbeyond.education/#";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1321;
  };

  "OnePrep" = {
    id = "aa3333333-3333-4333-8333-333333333333";
    url = "https://www.oneprep.xyz/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1322;
  };

  "KCL Tech Summit" = {
    id = "aa4444444-4444-4444-8444-444444444444";
    url = "https://www.kcltech.co.uk/techsummit25";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1323;
  };

  "BA Work Experience" = {
    id = "aa5555555-5555-4555-8555-555555555555";
    url = "https://apply.ba.com/emergingtalent/vacancy/work-experience-placement---heathrow-engineering-january-to-march-2026-11050-waterside-british-airways-head-office-london/11069/description/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1324;
  };

  "Samsung Solve" = {
    id = "aa6666666-6666-4666-8666-666666666666";
    url = "https://www.samsung.com/uk/solvefortomorrow/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1325;
  };

  "CREST Gold" = {
    id = "aa7777777-7777-4777-8777-777777777777";
    url = "https://www.crestawards.org/secondary-further-education/gold/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1326;
  };

  "Keep Future Human" = {
    id = "aa8888888-8888-4888-8888-888888888888";
    url = "https://keepthefuturehuman.ai/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1327;
  };

  "engNRICH" = {
    id = "aa9999999-9999-4999-8999-999999999999";
    url = "https://nrich.maths.org/engnrich";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1328;
  };

  "Semiconductor Award" = {
    id = "ab1111111-1111-4111-8111-111111111111";
    url = "https://www.ukesf.org/semiconductor-talent-award/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1329;
  };

  "20 Under 20" = {
    id = "ab2222222-2222-4222-8222-222222222222";
    url = "https://meeting.springpod.com/20-under-20";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1330;
  };

  "I Want Study Engineering" = {
    id = "ab3333333-3333-4333-8333-333333333333";
    url = "https://i-want-to-study-engineering.org/";
    workspace = spaces.Home.id;
    folderParentId = yr13.id;
    position = 1331;
  };

  # GSOC subfolder
  "GSOC Timeline" = {
    id = "ac1111111-1111-4111-8111-111111111111";
    url = "https://developers.google.com/open-source/gsoc/timeline";
    workspace = spaces.Home.id;
    folderParentId = gsoc.id;
    position = 1340;
  };

  "Google Open Source" = {
    id = "ac2222222-2222-4222-8222-222222222222";
    url = "https://opensource.googleblog.com/";
    workspace = spaces.Home.id;
    folderParentId = gsoc.id;
    position = 1341;
  };

  "GSOC First Contact" = {
    id = "ac3333333-3333-4333-8333-333333333333";
    url = "https://google.github.io/gsocguides/student/making-first-contact";
    workspace = spaces.Home.id;
    folderParentId = gsoc.id;
    position = 1342;
  };

  # MLH subfolder
  "MLH Fellowship" = {
    id = "ad1111111-1111-4111-8111-111111111111";
    url = "https://fellowship.mlh.io/";
    workspace = spaces.Home.id;
    folderParentId = mlh.id;
    position = 1350;
  };

  # Outreachy subfolder
  "Outreachy Guide" = {
    id = "ae1111111-1111-4111-8111-111111111111";
    url = "https://www.outreachy.org/docs/applicant/";
    workspace = spaces.Home.id;
    folderParentId = outreachy.id;
    position = 1360;
  };

  "Outreachy Home" = {
    id = "ae2222222-2222-4222-8222-222222222222";
    url = "https://www.outreachy.org/";
    workspace = spaces.Home.id;
    folderParentId = outreachy.id;
    position = 1361;
  };

  # Ayo Level Resources pins
  "ExamQ Maths" = {
    id = "af1111111-1111-4111-8111-111111111111";
    url = "https://www.examq.co.uk/qualification/ahtaxu";
    workspace = spaces.Home.id;
    folderParentId = ayoLevelResources.id;
    position = 1410;
  };

  "XtremePapers Maths" = {
    id = "af2222222-2222-4222-8222-222222222222";
    url = "https://papers.xtremepape.rs/index.php?dirpath=./Edexcel/Advanced+Level/Mathematics/&order=0";
    workspace = spaces.Home.id;
    folderParentId = ayoLevelResources.id;
    position = 1411;
  };

  "XtremePapers Biology" = {
    id = "af3333333-3333-4333-8333-333333333333";
    url = "https://papers.xtremepape.rs/index.php?dirpath=./Edexcel/Advanced+Level/Biology/&order=0";
    workspace = spaces.Home.id;
    folderParentId = ayoLevelResources.id;
    position = 1412;
  };

  "IGCSE Centre" = {
    id = "af4444444-4444-4444-8444-444444444444";
    url = "https://igcsecentre.com/about-igcse-centre/";
    workspace = spaces.Home.id;
    folderParentId = ayoLevelResources.id;
    position = 1413;
  };

  # U-knees pins
  "IMechE CV Guide" = {
    id = "ag1111111-1111-4111-8111-111111111111";
    url = "https://imeche.org/careers-education/careers-information/mechanical-engineering-careers-guide/write-a-great-cv";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1510;
  };

  "93% Club" = {
    id = "ag2222222-2222-4222-8222-222222222222";
    url = "https://www.93percent.club/students#typeform";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1511;
  };

  "IC Hack" = {
    id = "ag3333333-3333-4333-8333-333333333333";
    url = "https://ichack.org/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1512;
  };

  "Engineering Scholarships" = {
    id = "ag4444444-4444-4444-8444-444444444444";
    url = "https://www.borntoengineer.com/resources/engineering-scholarship";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1513;
  };

  "Non-Imperial Scholarships" = {
    id = "ag5555555-5555-4555-8555-555555555555";
    url = "https://www.imperial.ac.uk/students/fees-and-funding/undergraduate-funding/bursaries-and-scholarships/further-funding-opportunities-/external-awards/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1514;
  };

  "IET Scholarships" = {
    id = "ag6666666-6666-4666-8666-666666666666";
    url = "https://www.theiet.org/impact-society/awards-prizes-and-scholarships/iet-future-talent-awards";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1515;
  };

  "ICPC" = {
    id = "ag7777777-7777-4777-8777-777777777777";
    url = "https://icpc.global/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1516;
  };

  "AWE Sponsorship" = {
    id = "ag8888888-8888-4888-8888-888888888888";
    url = "https://www.awe.co.uk/careers/early-careers/defence-undergraduate-scholarship-scheme/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1517;
  };

  "Imperial Scholarships" = {
    id = "ag9999999-9999-4999-8999-999999999999";
    url = "https://www.imperial.ac.uk/materials/study/undergraduate/scholarships/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1518;
  };

  "Google Women in CS" = {
    id = "ah1111111-1111-4111-8111-111111111111";
    url = "https://www.iie.org/programs/generationgoogle/generation-google-scholarship-for-women-in-computer-science-europe-middle-east-and-africa-emea/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1519;
  };

  "Cyber Leaders" = {
    id = "ah2222222-2222-4222-8222-222222222222";
    url = "https://cyberleaderschallenge.com/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1520;
  };

  "Southampton Scholarship" = {
    id = "ah3333333-3333-4333-8333-333333333333";
    url = "https://www.southampton.ac.uk/study/fees-funding/scholarships/engineering-excellence-scholarship";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1521;
  };

  "The Residency" = {
    id = "ah4444444-4444-4444-8444-444444444444";
    url = "https://www.livetheresidency.com/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1522;
  };

  "BeyondAI Notion" = {
    id = "ah5555555-5555-4555-8555-555555555555";
    url = "https://thinkingbeyond.notion.site/BeyondAI-Introduction-to-AI-and-Research-Getting-ready-for-the-programme-edc0e088da424107a4a464be8b1de7c1";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1523;
  };

  "Asian Arab Network" = {
    id = "ah6666666-6666-4666-8666-666666666666";
    url = "https://www.linkedin.com/company/asianarabnetwork/about/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1524;
  };

  "Entrepreneurs First" = {
    id = "ah7777777-7777-4777-8777-777777777777";
    url = "https://apply.joinef.com/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1525;
  };

  "Blackbullion" = {
    id = "ah8888888-8888-4888-8888-888888888888";
    url = "https://www.blackbullion.com/?status=uni-student";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1526;
  };

  "Pi Wars Rules" = {
    id = "ah9999999-9999-4999-8999-999999999999";
    url = "https://piwars.org/2024-disaster-zone/rules/";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1527;
  };

  "Google AI Agents" = {
    id = "ai1111111-1111-4111-8111-111111111111";
    url = "https://rsvp.withgoogle.com/events/google-ai-agents-intensive_2025";
    workspace = spaces.Home.id;
    folderParentId = uknees.id;
    position = 1528;
  };

  # Imperial Stuff subfolder
  "Imperial College Union" = {
    id = "aj1111111-1111-4111-8111-111111111111";
    url = "https://www.imperialcollegeunion.org/";
    workspace = spaces.Home.id;
    folderParentId = imperialStuff.id;
    position = 1530;
  };

  # Courses subfolder
  "Imperial EIE" = {
    id = "ak1111111-1111-4111-8111-111111111111";
    url = "https://www.imperial.ac.uk/study/courses/undergraduate/electronic-information-meng/#abroad";
    workspace = spaces.Home.id;
    folderParentId = courses.id;
    position = 1540;
  };

  "Oxford Engineering" = {
    id = "ak2222222-2222-4222-8222-222222222222";
    url = "https://www.ox.ac.uk/admissions/undergraduate/courses/course-listing/engineering-science";
    workspace = spaces.Home.id;
    folderParentId = courses.id;
    position = 1541;
  };

  "Southampton EE" = {
    id = "ak3333333-3333-4333-8333-333333333333";
    url = "https://www.southampton.ac.uk/courses/electrical-engineering-degree-meng#fees";
    workspace = spaces.Home.id;
    folderParentId = courses.id;
    position = 1542;
  };

  "Cambridge Engineering" = {
    id = "ak4444444-4444-4444-8444-444444444444";
    url = "https://www.undergraduate.study.cam.ac.uk/courses/engineering-ba-hons-meng";
    workspace = spaces.Home.id;
    folderParentId = courses.id;
    position = 1543;
  };

  "LIS Prospectus" = {
    id = "ak5555555-5555-4555-8555-555555555555";
    url = "https://cdn.prod.website-files.com/64353ce03e49c4ef4602e6cf/691c48246e19487a102a6ab6_LIS%20BASc%20Prospectus%202026%205.pdf";
    workspace = spaces.Home.id;
    folderParentId = courses.id;
    position = 1544;
  };

  "TSR Imperial EIE" = {
    id = "ak6666666-6666-4666-8666-666666666666";
    url = "https://www.thestudentroom.co.uk/showthread.php?t=6030436";
    workspace = spaces.Home.id;
    folderParentId = courses.id;
    position = 1545;
  };

  # Engineering Resources subfolder
  "Cambridge Reading" = {
    id = "al1111111-1111-4111-8111-111111111111";
    url = "https://www.admissions.eng.cam.ac.uk/information/reading";
    workspace = spaces.Home.id;
    folderParentId = engineeringResources.id;
    position = 1550;
  };

  "Tomorrows Engineers" = {
    id = "al2222222-2222-4222-8222-222222222222";
    url = "https://www.tomorrowsengineers.org.uk/";
    workspace = spaces.Home.id;
    folderParentId = engineeringResources.id;
    position = 1551;
  };

  "Oxford Engineering Resources" = {
    id = "al3333333-3333-4333-8333-333333333333";
    url = "https://www.new.ox.ac.uk/engineering-resources";
    workspace = spaces.Home.id;
    folderParentId = engineeringResources.id;
    position = 1552;
  };

  # Post Uknee pins
  "Interdisciplinary Methods" = {
    id = "am1111111-1111-4111-8111-111111111111";
    url = "https://lisacuk.notion.site/Interdisciplinary-Problems-and-Methods-MASc-e3be8fcb9b1f4b06bbffb00fbaaed957";
    workspace = spaces.Home.id;
    folderParentId = postUknee.id;
    position = 1610;
  };

  "LIS Masters" = {
    id = "am2222222-2222-4222-8222-222222222222";
    url = "https://www.lis.ac.uk/graduate-degree";
    workspace = spaces.Home.id;
    folderParentId = postUknee.id;
    position = 1611;
  };

  "LIS MBA" = {
    id = "am3333333-3333-4333-8333-333333333333";
    url = "https://www.lis.ac.uk/mba";
    workspace = spaces.Home.id;
    folderParentId = postUknee.id;
    position = 1612;
  };

  # Undergraduate subfolder
  "LIS BASc Prospectus" = {
    id = "an1111111-1111-4111-8111-111111111111";
    url = "https://cdn.prod.website-files.com/64353ce03e49c4ef4602e6cf/691c48246e19487a102a6ab6_LIS%20BASc%20Prospectus%202026%205.pdf";
    workspace = spaces.Home.id;
    folderParentId = undergraduate.id;
    position = 1620;
  };

  # Postgraduate subfolder
  "LIS Masters Brochure" = {
    id = "ao1111111-1111-4111-8111-111111111111";
    url = "https://www.lis.ac.uk/masters-brochure-download";
    workspace = spaces.Home.id;
    folderParentId = postgraduate.id;
    position = 1630;
  };

  "LIS MASc Brochure" = {
    id = "ao2222222-2222-4222-8222-222222222222";
    url = "https://cdn.prod.website-files.com/64353ce03e49c4ef4602e6cf/68c42a9d29fbf570082e5a3b_LIS%20MASc%20Brochure%202026%201.pdf";
    workspace = spaces.Home.id;
    folderParentId = postgraduate.id;
    position = 1631;
  };

  # ---- Pins in Programming Space ----

  # Dev-Ices subfolder pins
  "Fydetab Duo" = {
    id = "ap1111111-1111-4111-8111-111111111111";
    url = "https://github.com/NixOS/nixos-hardware/tree/master/fydetab/duo";
    workspace = spaces.Programming.id;
    folderParentId = devIces.id;
    position = 3110;
  };

  # nixOS subfolder pins
  "Disko" = {
    id = "aq1111111-1111-4111-8111-111111111111";
    url = "https://github.com/nix-community/disko";
    workspace = spaces.Programming.id;
    folderParentId = nixOS.id;
    position = 3210;
  };

  "Denix" = {
    id = "aq2222222-2222-4222-8222-222222222222";
    url = "https://github.com/yunfachi/denix";
    workspace = spaces.Programming.id;
    folderParentId = nixOS.id;
    position = 3211;
  };

  "NixOS Btrfs" = {
    id = "aq3333333-3333-4333-8333-333333333333";
    url = "https://www.reddit.com/r/NixOS/comments/1bqm7hv/do_you_use_btrfs/";
    workspace = spaces.Programming.id;
    folderParentId = nixOS.id;
    position = 3212;
  };

  # Pog-ramming subfolder pins
  "US Graphics" = {
    id = "ar1111111-1111-4111-8111-111111111111";
    url = "https://usgraphics.com/";
    workspace = spaces.Programming.id;
    folderParentId = pogRamming.id;
    position = 3310;
  };

  "OSHub" = {
    id = "ar2222222-2222-4222-8222-222222222222";
    url = "https://oshub.org/";
    workspace = spaces.Programming.id;
    folderParentId = pogRamming.id;
    position = 3311;
  };

  # Raspberry Pi subfolder pins
  "Raspberry Pi Connect" = {
    id = "as1111111-1111-4111-8111-111111111111";
    url = "https://connect.raspberrypi.com/devices";
    workspace = spaces.Programming.id;
    folderParentId = raspberryPi.id;
    position = 3410;
  };

  "RPI Screen Share" = {
    id = "as2222222-2222-4222-8222-222222222222";
    url = "https://connect.raspberrypi.com/devices/0ddb991f-8e0d-4dee-853c-64693b5acde7/screen-sharing-session";
    workspace = spaces.Programming.id;
    folderParentId = raspberryPi.id;
    position = 3411;
  };

  "SSD Not Detected" = {
    id = "as3333333-3333-4333-8333-333333333333";
    url = "https://forums.raspberrypi.com/viewtopic.php?p=2349036#p2349036";
    workspace = spaces.Programming.id;
    folderParentId = raspberryPi.id;
    position = 3412;
  };

  # ---- Pins in F1 in Schools Space ----

  # Pinned tabs for F1 in Schools space
  "WARP Racing" = {
    id = "at1111111-1111-4111-8111-111111111111";
    url = "https://warp-racing.com/";
    workspace = spaces."F1 in Schools".id;
    position = 2100;
  };

  "WARP Racing Links" = {
    id = "at2222222-2222-4222-8222-222222222222";
    url = "https://warp-racing.com/?show_links=true";
    workspace = spaces."F1 in Schools".id;
    position = 2101;
  };

  "WARP GoFundMe" = {
    id = "at3333333-3333-4333-8333-333333333333";
    url = "https://www.gofundme.com/manage/help-warp-get-to-the-uk-national-finals";
    workspace = spaces."F1 in Schools".id;
    position = 2102;
  };

  "cPanel Tools" = {
    id = "at4444444-4444-4444-8444-444444444444";
    url = "https://server130.web-hosting.com:2083/cpsess1308199535/frontend/jupiter/index.html?login=1&post_login=3200853608743";
    workspace = spaces."F1 in Schools".id;
    position = 2103;
  };

  "Roundcube Webmail" = {
    id = "at5555555-5555-4555-8555-555555555555";
    url = "https://server130.web-hosting.com:2096/cpsess7886695237/3rdparty/roundcube/?_task=mail&_mbox=INBOX";
    workspace = spaces."F1 in Schools".id;
    position = 2104;
  };

  "WARP LinkedIn" = {
    id = "at6666666-6666-4666-8666-666666666666";
    url = "https://www.linkedin.com/company/101804972/admin/notifications/all/";
    workspace = spaces."F1 in Schools".id;
    position = 2105;
  };

  "Instagram" = {
    id = "at7777777-7777-4777-8777-777777777777";
    url = "https://www.instagram.com/";
    workspace = spaces."F1 in Schools".id;
    position = 2106;
  };

  "WARP WhatsApp" = {
    id = "at8888888-8888-4888-8888-888888888888";
    url = "https://www.whatsapp.com/channel/0029VbBRYAE2P59kigjboH0n";
    workspace = spaces."F1 in Schools".id;
    position = 2107;
  };

  "WARP YouTube" = {
    id = "at9999999-9999-4999-8999-999999999999";
    url = "https://www.youtube.com/@warp_racing/videos";
    workspace = spaces."F1 in Schools".id;
    position = 2108;
  };

  "Facebook" = {
    id = "au1111111-1111-4111-8111-111111111111";
    url = "https://www.facebook.com/warp.racing";
    workspace = spaces."F1 in Schools".id;
    position = 2109;
  };

  "Threads" = {
    id = "au2222222-2222-4222-8222-222222222222";
    url = "https://www.threads.com/@warp_racing";
    workspace = spaces."F1 in Schools".id;
    position = 2110;
  };

  "Umami Analytics" = {
    id = "au3333333-3333-4333-8333-333333333333";
    url = "https://cloud.umami.is/analytics/eu/websites/34c0f985-73f0-4f79-a58e-33f5daa4d064";
    workspace = spaces."F1 in Schools".id;
    position = 2111;
  };

  "World Finals Combo" = {
    id = "au4444444-4444-4444-8444-444444444444";
    url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx";
    workspace = spaces."F1 in Schools".id;
    position = 2112;
  };

  "GitHub Dev" = {
    id = "au5555555-5555-4555-8555-555555555555";
    url = "https://silver-space-meme-9v54pgvq7g5c9x9g.github.dev/";
    workspace = spaces."F1 in Schools".id;
    position = 2113;
  };

  # Scorecards in F1 in Schools space
  "WARP Results" = {
    id = "av1111111-1111-4111-8111-111111111111";
    url = "https://stolavesgrammarschool.sharepoint.com/sites/F1inSchools2025-26-PRO-12-Warp/Shared%20Documents/PRO%20-%2012%20-%20Warp/P02%20-%20Warp%20-%20St%20Olave%27s%20-%20Results.pdf";
    workspace = spaces."F1 in Schools".id;
    position = 2200;
  };
}
