# nix (complete reconstruction)
let
  containers = import ./containers.nix;
  spaces = import ./spaces.nix;

  # ---- Folder Variables ----

  # Year 12 Folder
  year12 = {
    id = "e5555555-5555-4555-8555-555555555555";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 1000;
  };

  # Year 13 Folder
  year13 = {
    id = "g7777777-7777-4777-8777-777777777777";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 1100;
  };

  # University Research (subfolder of Year 13)
  universityResearch = {
    id = "h8888888-8888-4888-8888-888888888888";
    workspace = spaces.Home.id;
    folderParentId = year13.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 1101;
  };

  # A-Level Subjects (subfolder of Year 13)
  aLevelSubjects = {
    id = "i9999999-9999-4999-8999-999999999999";
    workspace = spaces.Home.id;
    folderParentId = year13.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 1200;
  };

  # Physics Revision (subfolder of A-Level Subjects)
  physicsRevision = {
    id = "j0000000-0000-4000-8000-000000000000";
    workspace = spaces.Home.id;
    folderParentId = aLevelSubjects.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 1201;
  };

  # Mathematics (subfolder of A-Level Subjects)
  mathematics = {
    id = "n4444444-4444-4444-8444-444444444445";
    workspace = spaces.Home.id;
    folderParentId = aLevelSubjects.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 1300;
  };

  # Biology (subfolder of A-Level Subjects)
  biology = {
    id = "q7777777-7777-4777-8777-777777777778";
    workspace = spaces.Home.id;
    folderParentId = aLevelSubjects.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 1400;
  };

  # Ukness (Universities) Folder
  uknessUniversities = {
    id = "s9999999-9999-4999-8999-999999999990";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2000;
  };

  # Cambridge (subfolder of Ukness)
  cambridge = {
    id = "t0000000-0000-4000-8000-000000000001";
    workspace = spaces.Home.id;
    folderParentId = uknessUniversities.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2001;
  };

  # Oxford (subfolder of Ukness)
  oxford = {
    id = "z6666666-6666-4666-8666-666666666668";
    workspace = spaces.Home.id;
    folderParentId = uknessUniversities.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2100;
  };

  # Imperial (subfolder of Ukness)
  imperial = {
    id = "e1111111-1111-4111-8111-111111111114";
    workspace = spaces.Home.id;
    folderParentId = uknessUniversities.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2200;
  };

  # Southampton (subfolder of Ukness)
  southampton = {
    id = "m9999999-9999-4999-8999-999999999992";
    workspace = spaces.Home.id;
    folderParentId = uknessUniversities.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2300;
  };

  # LIS (subfolder of Ukness)
  lis = {
    id = "p2222222-2222-4222-8222-222222222226";
    workspace = spaces.Home.id;
    folderParentId = uknessUniversities.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2400;
  };

  # Kings College (subfolder of Ukness)
  kingsCollege = {
    id = "v8888888-8888-4888-8888-888888888892";
    workspace = spaces.Home.id;
    folderParentId = uknessUniversities.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2500;
  };

  # UCL (subfolder of Ukness)
  ucl = {
    id = "y1111111-1111-4111-8111-111111111116";
    workspace = spaces.Home.id;
    folderParentId = uknessUniversities.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 2600;
  };

  # Ark-wright Folder
  arkwright = {
    id = "a3333333-3333-4333-8333-333333333338";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 3000;
  };

  # Application (subfolder of Ark-wright)
  application = {
    id = "b4444444-4444-4444-8444-444444444449";
    workspace = spaces.Home.id;
    folderParentId = arkwright.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 3001;
  };

  # Resources (subfolder of Ark-wright)
  resources = {
    id = "f8888888-8888-4888-8888-888888888893";
    workspace = spaces.Home.id;
    folderParentId = arkwright.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 3100;
  };

  # Shopping Ideas (subfolder of Ark-wright)
  shoppingIdeas = {
    id = "j2222222-2222-4222-8222-222222222228";
    workspace = spaces.Home.id;
    folderParentId = arkwright.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 3200;
  };

  # Gallery (subfolder of Ark-wright)
  gallery = {
    id = "p8888888-8888-4888-8888-888888888894";
    workspace = spaces.Home.id;
    folderParentId = arkwright.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 3300;
  };

  # Work Experience Folder
  workExperience = {
    id = "s1111111-1111-4111-8111-111111111118";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 4000;
  };

  # Company Listings (subfolder of Work Experience)
  companyListings = {
    id = "v4444444-4444-4444-8444-444444444451";
    workspace = spaces.Home.id;
    folderParentId = workExperience.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 4100;
  };

  # Programmes Folder
  programmes = {
    id = "s7777777-7777-4777-8777-777777777786";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 5000;
  };

  # Smallpeice (subfolder of Programmes)
  smallpeice = {
    id = "t8888888-8888-4888-8888-888888888897";
    workspace = spaces.Home.id;
    folderParentId = programmes.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 5001;
  };

  # Sutton Trust (subfolder of Programmes)
  suttonTrust = {
    id = "w1111111-1111-4111-8111-111111111121";
    workspace = spaces.Home.id;
    folderParentId = programmes.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 5100;
  };

  # Other Schemes (subfolder of Programmes)
  otherSchemes = {
    id = "y3333333-3333-4333-8333-333333333343";
    workspace = spaces.Home.id;
    folderParentId = programmes.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 5200;
  };

  # Scholarships Folder
  scholarships = {
    id = "j4444444-4444-4444-8444-444444444455";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 6000;
  };

  # Competitions Folder
  competitions = {
    id = "r2222222-2222-4222-8222-222222222234";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 7000;
  };

  # BIO (subfolder of Competitions)
  bio = {
    id = "s3333333-3333-4333-8333-333333333345";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 7001;
  };

  # NASA Space Apps (subfolder of Competitions)
  nasaSpaceApps = {
    id = "x8888888-8888-4888-8888-888888888900";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 7100;
  };

  # Other Competitions (subfolder of Competitions)
  otherCompetitions = {
    id = "a1111111-1111-4111-8111-111111111124";
    workspace = spaces.Home.id;
    folderParentId = competitions.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 7200;
  };

  # Incubators/Accelerators Folder
  incubatorsAccelerators = {
    id = "l2222222-2222-4222-8222-222222222236";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 8000;
  };

  # Technical/Programming Folder
  technicalProgramming = {
    id = "q7777777-7777-4777-8777-777777777791";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 9000;
  };

  # Open Source (subfolder of Technical/Programming)
  openSource = {
    id = "r8888888-8888-4888-8888-888888888902";
    workspace = spaces.Home.id;
    folderParentId = technicalProgramming.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 9001;
  };

  # AI (subfolder of Technical/Programming)
  ai = {
    id = "c9999999-9999-4999-8999-999999999995";
    workspace = spaces.Home.id;
    folderParentId = technicalProgramming.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 9100;
  };

  # NixOS (subfolder of Technical/Programming)
  nixos = {
    id = "o1111111-1111-4111-8111-111111111128";
    workspace = spaces.Home.id;
    folderParentId = technicalProgramming.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 9200;
  };

  # Other Tools (subfolder of Technical/Programming)
  otherTools = {
    id = "t6666666-6666-4666-8666-666666666683";
    workspace = spaces.Home.id;
    folderParentId = technicalProgramming.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 9300;
  };

  # F1 in Schools Folder
  f1isResources = {
    id = "a3333333-3333-4333-8333-333333333351";
    workspace = spaces."F1 in Schools".id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 10000;
  };

  # RPI/Programming Folder
  rpiProgramming = {
    id = "d6666666-6666-4666-8666-666666666684";
    workspace = spaces.Programming.id;
    isGroup = true;
    isFolderCollapsed = false;
    editedTitle = true;
    position = 11000;
  };

in
{
  # ---- Essential pins (Home container) ----

  Spotify = {
    id = "a1111111-1111-4111-8111-111111111111";
    url = "https://open.spotify.com";
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

  DeepSeek = {
    id = "c3333333-3333-4333-8333-333333333333";
    url = "https://chat.deepseek.com";
    container = containers.Home.id;
    isEssential = true;
    position = 102;
  };

  Gemini = {
    id = "d4444444-4444-4444-8444-444444444444";
    url = "https://gemini.google.com";
    container = containers.Home.id;
    isEssential = true;
    position = 103;
  };

  # ---- Folder Structure ----

  # Year 12 Folder
  "Year 12" = year12;

  "OCR Computer Science PDF" = {
    id = "f6666666-6666-4666-8666-666666666666";
    workspace = spaces.Home.id;
    folderParentId = year12.id;
    url = "file:///run/media/ami/Main/School%20Stuff/Year%2012/OCR%20AS%20and%20A%20Level%20Computer%20Science%20by%20Heathcote%20P%20M,%20Heathcote%20R%20S%20U.pdf";
    position = 1001;
  };

  # Year 13 Folder
  "Year 13" = year13;

  # University Research (subfolder of Year 13)
  "University Research" = universityResearch;

  # A-Level Subjects (subfolder of Year 13)
  "A-Level Subjects" = aLevelSubjects;

  # Physics Revision (subfolder of A-Level Subjects)
  "Physics Revision" = physicsRevision;

  "OCR Physics Questions" = {
    id = "k1111111-1111-4111-8111-111111111112";
    workspace = spaces.Home.id;
    folderParentId = physicsRevision.id;
    url = "https://www.revisely.com/alevel/physics/ocr/questions";
    position = 1202;
  };

  "Physics & Maths Tutor" = {
    id = "l2222222-2222-4222-8222-222222222223";
    workspace = spaces.Home.id;
    folderParentId = physicsRevision.id;
    url = "https://www.physicsandmathstutor.com/physics-revision/a-level-ocr-a/";
    position = 1203;
  };

  "Online Physics Tutor" = {
    id = "m3333333-3333-4333-8333-333333333334";
    workspace = spaces.Home.id;
    folderParentId = physicsRevision.id;
    url = "https://theonlinephysicstutor.com/ocr-a-physics-worksheets.html";
    position = 1204;
  };

  # Mathematics (subfolder of A-Level Subjects)
  "Mathematics" = mathematics;

  "ExamQ Maths" = {
    id = "o5555555-5555-4555-8555-555555555556";
    workspace = spaces.Home.id;
    folderParentId = mathematics.id;
    url = "https://www.examq.co.uk/qualification/ahtaxu";
    position = 1301;
  };

  "Maths Past Papers" = {
    id = "p6666666-6666-4666-8666-666666666667";
    workspace = spaces.Home.id;
    folderParentId = mathematics.id;
    url = "https://papers.xtremepape.rs/index.php?dirpath=./Edexcel/Advanced+Level/Mathematics/&order=0";
    position = 1302;
  };

  # Biology (subfolder of A-Level Subjects)
  "Biology" = biology;

  "Biology Past Papers" = {
    id = "r8888888-8888-4888-8888-888888888889";
    workspace = spaces.Home.id;
    folderParentId = biology.id;
    url = "https://papers.xtremepape.rs/index.php?dirpath=./Edexcel/Advanced+Level/Biology/&order=0";
    position = 1401;
  };

  # Ukness (Universities) Folder
  "Ukness (Universities)" = uknessUniversities;

  # Cambridge (subfolder of Ukness)
  "Cambridge" = cambridge;

  "Cambridge Engineering" = {
    id = "u1111111-1111-4111-8111-111111111113";
    workspace = spaces.Home.id;
    folderParentId = cambridge.id;
    url = "https://www.undergraduate.study.cam.ac.uk/courses/engineering-ba-hons-meng";
    position = 2002;
  };

  "STEM SMART Cambridge" = {
    id = "v2222222-2222-4222-8222-222222222224";
    workspace = spaces.Home.id;
    folderParentId = cambridge.id;
    url = "https://www.undergraduate.study.cam.ac.uk/stem-smart";
    position = 2003;
  };

  "Sutton Trust Cambridge" = {
    id = "w3333333-3333-4333-8333-333333333335";
    workspace = spaces.Home.id;
    folderParentId = cambridge.id;
    url = "https://www.undergraduate.study.cam.ac.uk/events/summer-schools";
    position = 2004;
  };

  "Caius 12" = {
    id = "x4444444-4444-4444-8444-444444444446";
    workspace = spaces.Home.id;
    folderParentId = cambridge.id;
    url = "https://www.cai.cam.ac.uk/access-outreach/schemes-and-events/caius-12";
    position = 2005;
  };

  "Cambridge Reading List" = {
    id = "y5555555-5555-4555-8555-555555555557";
    workspace = spaces.Home.id;
    folderParentId = cambridge.id;
    url = "https://www.admissions.eng.cam.ac.uk/information/reading";
    position = 2006;
  };

  # Oxford (subfolder of Ukness)
  "Oxford" = oxford;

  "Oxford Engineering" = {
    id = "a7777777-7777-4777-8777-777777777779";
    workspace = spaces.Home.id;
    folderParentId = oxford.id;
    url = "https://www.ox.ac.uk/admissions/undergraduate/courses/course-listing/engineering-science";
    position = 2101;
  };

  "COMPOS Oxford" = {
    id = "b8888888-8888-4888-8888-888888888890";
    workspace = spaces.Home.id;
    folderParentId = oxford.id;
    url = "https://compos.web.ox.ac.uk/home";
    position = 2102;
  };

  "Quantum Club Oxford" = {
    id = "c9999999-9999-4999-8999-999999999991";
    workspace = spaces.Home.id;
    folderParentId = oxford.id;
    url = "https://www.physics.ox.ac.uk/engage/schools/secondary-schools/projects-and-mentoring/quantum-club";
    position = 2103;
  };

  "Oxford Engineering Resources" = {
    id = "d0000000-0000-4000-8000-000000000002";
    workspace = spaces.Home.id;
    folderParentId = oxford.id;
    url = "https://www.new.ox.ac.uk/engineering-resources";
    position = 2104;
  };

  # Imperial (subfolder of Ukness)
  "Imperial" = imperial;

  "Imperial EIE" = {
    id = "f2222222-2222-4222-8222-222222222225";
    workspace = spaces.Home.id;
    folderParentId = imperial.id;
    url = "https://www.imperial.ac.uk/study/courses/undergraduate/electronic-information-meng";
    position = 2201;
  };

  "Imperial Work Experience" = {
    id = "g3333333-3333-4333-8333-333333333336";
    workspace = spaces.Home.id;
    folderParentId = imperial.id;
    url = "https://www.imperial.ac.uk/be-inspired/schools-outreach/secondary-schools/summer-schools/work-experience/";
    position = 2202;
  };

  "Imperial Sutton Trust" = {
    id = "h4444444-4444-4444-8444-444444444447";
    workspace = spaces.Home.id;
    folderParentId = imperial.id;
    url = "https://www.imperial.ac.uk/be-inspired/schools-outreach/secondary-schools/summer-schools/sutton-trust/";
    position = 2203;
  };

  "Imperial Scholarships" = {
    id = "i5555555-5555-4555-8555-555555555558";
    workspace = spaces.Home.id;
    folderParentId = imperial.id;
    url = "https://www.imperial.ac.uk/students/fees-and-funding/undergraduate-funding/bursaries-and-scholarships/further-funding-opportunities-/external-awards/";
    position = 2204;
  };

  "Imperial Materials Scholarships" = {
    id = "j6666666-6666-4666-8666-666666666669";
    workspace = spaces.Home.id;
    folderParentId = imperial.id;
    url = "https://www.imperial.ac.uk/materials/study/undergraduate/scholarships/";
    position = 2205;
  };

  "Imperial College Union" = {
    id = "k7777777-7777-4777-8777-777777777780";
    workspace = spaces.Home.id;
    folderParentId = imperial.id;
    url = "https://www.imperialcollegeunion.org/";
    position = 2206;
  };

  "Student Room Imperial" = {
    id = "l8888888-8888-4888-8888-888888888891";
    workspace = spaces.Home.id;
    folderParentId = imperial.id;
    url = "https://www.thestudentroom.co.uk/showthread.php?t=6030436";
    position = 2207;
  };

  # Southampton (subfolder of Ukness)
  "Southampton" = southampton;

  "Southampton EE" = {
    id = "n0000000-0000-4000-8000-000000000003";
    workspace = spaces.Home.id;
    folderParentId = southampton.id;
    url = "https://www.southampton.ac.uk/courses/electrical-engineering-degree-meng";
    position = 2301;
  };

  "Southampton Scholarships" = {
    id = "o1111111-1111-4111-8111-111111111115";
    workspace = spaces.Home.id;
    folderParentId = southampton.id;
    url = "https://www.southampton.ac.uk/study/fees-funding/scholarships/engineering-excellence-scholarship";
    position = 2302;
  };

  # LIS (subfolder of Ukness)
  "LIS" = lis;

  "LIS Prospectus" = {
    id = "q3333333-3333-4333-8333-333333333337";
    workspace = spaces.Home.id;
    folderParentId = lis.id;
    url = "https://cdn.prod.website-files.com/64353ce03e49c4ef4602e6cf/691c48246e19487a102a6ab6_LIS%20BASc%20Prospectus%202026%205.pdf";
    position = 2401;
  };

  "LIS MASc" = {
    id = "r4444444-4444-4444-8444-444444444448";
    workspace = spaces.Home.id;
    folderParentId = lis.id;
    url = "https://cdn.prod.website-files.com/64353ce03e49c4ef4602e6cf/68c42a9d29fbf570082e5a3b_LIS%20MASc%20Brochure%202026%201.pdf";
    position = 2402;
  };

  "LIS Graduate Degree" = {
    id = "s5555555-5555-4555-8555-555555555559";
    workspace = spaces.Home.id;
    folderParentId = lis.id;
    url = "https://www.lis.ac.uk/graduate-degree";
    position = 2403;
  };

  "LIS MBA" = {
    id = "t6666666-6666-4666-8666-666666666670";
    workspace = spaces.Home.id;
    folderParentId = lis.id;
    url = "https://www.lis.ac.uk/mba";
    position = 2404;
  };

  "LIS Interdisciplinary" = {
    id = "u7777777-7777-4777-8777-777777777781";
    workspace = spaces.Home.id;
    folderParentId = lis.id;
    url = "https://lisacuk.notion.site/Interdisciplinary-Problems-and-Methods-MASc-e3be8fcb9b1f4b06bbffb00fbaaed957";
    position = 2405;
  };

  # Kings College (subfolder of Ukness)
  "Kings College" = kingsCollege;

  "KCL Summer School" = {
    id = "w9999999-9999-4999-8999-999999999993";
    workspace = spaces.Home.id;
    folderParentId = kingsCollege.id;
    url = "https://www.kcl.ac.uk/summer/summer-on-campus/pre-university-summer-school";
    position = 2501;
  };

  "KCL Tech Summit" = {
    id = "x0000000-0000-4000-8000-000000000004";
    workspace = spaces.Home.id;
    folderParentId = kingsCollege.id;
    url = "https://www.kcltech.co.uk/techsummit25";
    position = 2502;
  };

  # UCL (subfolder of Ukness)
  "UCL" = ucl;

  "UCL Work Experience" = {
    id = "z2222222-2222-4222-8222-222222222227";
    workspace = spaces.Home.id;
    folderParentId = ucl.id;
    url = "https://www.ucl.ac.uk/engineering/work-experience-ucl-mechanical-engineering";
    position = 2601;
  };

  # Ark-wright Folder
  "Ark-wright" = arkwright;

  # Application (subfolder of Ark-wright)
  "Application" = application;

  "Smallpeice Login" = {
    id = "c5555555-5555-4555-8555-555555555560";
    workspace = spaces.Home.id;
    folderParentId = application.id;
    url = "https://thesmallpeicetrust.smapply.io/acc/l/?next=/sub/31863595/";
    position = 3002;
  };

  "Smallpeice Events" = {
    id = "d6666666-6666-4666-8666-666666666671";
    workspace = spaces.Home.id;
    folderParentId = application.id;
    url = "https://www.smallpeicetrust.org.uk/events-calendar/";
    position = 3003;
  };

  "Smallpeice Future Scholar" = {
    id = "e7777777-7777-4777-8777-777777777782";
    workspace = spaces.Home.id;
    folderParentId = application.id;
    url = "https://www.smallpeicetrust.org.uk/i-am-a-future-scholar/";
    position = 3004;
  };

  # Resources (subfolder of Ark-wright)
  "Resources" = resources;

  "CS Exemplar Project" = {
    id = "g9999999-9999-4999-8999-999999999994";
    workspace = spaces.Home.id;
    folderParentId = resources.id;
    url = "https://smallpeicetrust.org.uk/downloads/exemplar-projects/exemplar-projects-4---computer-science-project-lr.pdf";
    position = 3101;
  };

  "How to Succeed Guide" = {
    id = "h0000000-0000-4000-8000-000000000005";
    workspace = spaces.Home.id;
    folderParentId = resources.id;
    url = "https://smallpeicetrust.org.uk/downloads/arkwright-documents/how-to-succeed-in-the-arkwright-application-august-2024.pdf";
    position = 3102;
  };

  "Arkwright Handbook" = {
    id = "i1111111-1111-4111-8111-111111111117";
    workspace = spaces.Home.id;
    folderParentId = resources.id;
    url = "https://smallpeicetrust.org.uk/arkwright-engineering-scholarships/downloads/arkwright-documents/2024-arkwright-engineering-scholarships-handbookv1.pdf";
    position = 3103;
  };

  # Shopping Ideas (subfolder of Ark-wright)
  "Shopping Ideas" = shoppingIdeas;

  "Phone Stands" = {
    id = "k3333333-3333-4333-8333-333333333339";
    workspace = spaces.Home.id;
    folderParentId = shoppingIdeas.id;
    url = "https://www.aliexpress.com/w/wholesale-phone-stand.html?spm=a2g0o.productlist.search.0";
    position = 3201;
  };

  "UGREEN Power Bank" = {
    id = "l4444444-4444-4444-8444-444444444450";
    workspace = spaces.Home.id;
    folderParentId = shoppingIdeas.id;
    url = "https://www.amazon.co.uk/UGREEN-20000mAh-Charging-Portable-Compatible/dp/B0DSPVDYQ9";
    position = 3202;
  };

  "MagSafe Table Mount" = {
    id = "m5555555-5555-4555-8555-555555555561";
    workspace = spaces.Home.id;
    folderParentId = shoppingIdeas.id;
    url = "https://www.amazon.co.uk/s?k=magsafe+table+mount&i=electronics";
    position = 3203;
  };

  "Monitor Arms" = {
    id = "n6666666-6666-4666-8666-666666666672";
    workspace = spaces.Home.id;
    folderParentId = shoppingIdeas.id;
    url = "https://www.aliexpress.com/w/wholesale-monitor-arms.html?spm=a2g0o.productlist.search.0";
    position = 3204;
  };

  "MagSafe Clamp" = {
    id = "o7777777-7777-4777-8777-777777777783";
    workspace = spaces.Home.id;
    folderParentId = shoppingIdeas.id;
    url = "https://www.aliexpress.com/w/wholesale-magsafe-tabl-clamp.html?spm=a2g0o.productlist.search.0";
    position = 3205;
  };

  # Gallery (subfolder of Ark-wright)
  "Gallery" = gallery;

  "Arkwright Networking" = {
    id = "q9999999-9999-4999-8999-999999999995";
    workspace = spaces.Home.id;
    folderParentId = gallery.id;
    url = "https://gallery.squireandsquire.co.uk/-arkwrightengineeringscholarshipsnetworkingeventsouth/gallery";
    position = 3301;
  };

  "Arkwright Photos" = {
    id = "r0000000-0000-4000-8000-000000000006";
    workspace = spaces.Home.id;
    folderParentId = gallery.id;
    url = "https://gallery.squireandsquire.co.uk/-arkwrightengineeringeventsouthgeneralphotography/store";
    position = 3302;
  };

  # Work Experience Folder
  "Work Experience" = workExperience;

  "Diamond Light Source" = {
    id = "t2222222-2222-4222-8222-222222222229";
    workspace = spaces.Home.id;
    folderParentId = workExperience.id;
    url = "https://www.diamond.ac.uk/Careers/Students/Schools-Work-Experience.html";
    position = 4001;
  };

  "Diamond Application" = {
    id = "u3333333-3333-4333-8333-333333333340";
    workspace = spaces.Home.id;
    folderParentId = workExperience.id;
    url = "https://forms.office.com/Pages/ResponsePage.aspx?id=dLonnQABDU2B_x1yja6N9hb0bxAKUSFBsNUl96r2ReZUMVU2TExHTU4yRjBXRVNXVUdRTlNHSlA1QyQlQCN0PWcu";
    position = 4002;
  };

  # Company Listings (subfolder of Work Experience)
  "Company Listings" = companyListings;

  "Leonardo Work Experience" = {
    id = "w5555555-5555-4555-8555-555555555562";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.uk.leonardo.com/gb/en/early-careers/placements/work-experience";
    position = 4101;
  };

  "Williams Racing" = {
    id = "x6666666-6666-4666-8666-666666666673";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://jobs.smartrecruiters.com/WilliamsRacing/744000036071671-work-experience-2025-";
    position = 4102;
  };

  "Williams Careers" = {
    id = "y7777777-7777-4777-8777-777777777784";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.williamsf1.com/early-careers";
    position = 4103;
  };

  "Workday" = {
    id = "z8888888-8888-4888-8888-888888888895";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://community.workday.com/maintenance-page";
    position = 4104;
  };

  "AtkinsRéalis" = {
    id = "a9999999-9999-4999-8999-999999999996";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.atkinsrealis.com/en/early-careers/uk/work-experience";
    position = 4105;
  };

  "STFC RAL" = {
    id = "b0000000-0000-4000-8000-000000000007";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://stfc-workexperience.co.uk/applyral/";
    position = 4106;
  };

  "Mott MacDonald" = {
    id = "c1111111-1111-4111-8111-111111111119";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://www.mottmac.com/en-gb/careers/early-careers/uk-europe/work-experience/";
    position = 4107;
  };

  "BAE Systems" = {
    id = "d2222222-2222-4222-8222-222222222230";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.baesystems.com/locations/uk/work-experience";
    position = 4108;
  };

  "Bentley Motors" = {
    id = "e3333333-3333-4333-8333-333333333341";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.bentleymotors.com/content/Early-Careers--Work-Experience-/";
    position = 4109;
  };

  "Rolls-Royce" = {
    id = "f4444444-4444-4444-8444-444444444452";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.rolls-royce.com/united-kingdom/students-and-graduates/work-experience";
    position = 4110;
  };

  "Softwire" = {
    id = "g5555555-5555-4555-8555-555555555563";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://www.softwire.com/careers/work-experience/";
    position = 4111;
  };

  "Costain" = {
    id = "h6666666-6666-4666-8666-666666666674";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://www.costain.com/careers/early-careers/work-experience/";
    position = 4112;
  };

  "Buro Happold" = {
    id = "i7777777-7777-4777-8777-777777777785";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://www.burohappold.com/work-experience-uk/";
    position = 4113;
  };

  "Kings College Hospital" = {
    id = "j8888888-8888-4888-8888-888888888896";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://www.kch.nhs.uk/careers/working-at-kings/work-experience/";
    position = 4114;
  };

  "Biggin Hill Airport" = {
    id = "k9999999-9999-4999-8999-999999999997";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://bigginhillairport.com/careers/early-careers/";
    position = 4115;
  };

  "AstraZeneca" = {
    id = "l0000000-0000-4000-8000-000000000008";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.astrazeneca.com/early-talent";
    position = 4116;
  };

  "Sellafield" = {
    id = "m1111111-1111-4111-8111-111111111120";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://careers.sellafieldsite.co.uk/graduates-placements/work-experience/application-process/";
    position = 4117;
  };

  "British Airways" = {
    id = "n2222222-2222-4222-8222-222222222231";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://apply.ba.com/emergingtalent/vacancy/work-experience-placement---heathrow-engineering-january-to-march-2026-11050-waterside-british-airways-head-office-london/11069/description/";
    position = 4118;
  };

  "Ramboll" = {
    id = "o3333333-3333-4333-8333-333333333342";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://www.ramboll.com/careers";
    position = 4119;
  };

  "Future Finder" = {
    id = "p4444444-4444-4444-8444-444444444453";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://finder.futuresforall.org/";
    position = 4120;
  };

  "Prospects Guide" = {
    id = "q5555555-5555-4555-8555-555555555564";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://www.prospects.ac.uk/further-education/year-12-work-experience/";
    position = 4121;
  };

  "Apprenticeship Events" = {
    id = "r6666666-6666-4666-8666-666666666675";
    workspace = spaces.Home.id;
    folderParentId = companyListings.id;
    url = "https://apprenticeships.co.uk/in-person-events";
    position = 4122;
  };

  # Programmes Folder
  "Programmes" = programmes;

  # Smallpeice (subfolder of Programmes)
  "Smallpeice" = smallpeice;

  "Smallpeice MentorNet" = {
    id = "u9999999-9999-4999-8999-999999999998";
    workspace = spaces.Home.id;
    folderParentId = smallpeice.id;
    url = "https://smallpeicetrust.sfgmentornet.com/auth/account/login";
    position = 5002;
  };

  "Smallpeice Course Types" = {
    id = "v0000000-0000-4000-8000-000000000009";
    workspace = spaces.Home.id;
    folderParentId = smallpeice.id;
    url = "https://www.smallpeicetrust.org.uk/events-calendar/?course_type=110";
    position = 5003;
  };

  # Sutton Trust (subfolder of Programmes)
  "Sutton Trust" = suttonTrust;

  "Sutton Trust US Programme" = {
    id = "x2222222-2222-4222-8222-222222222232";
    workspace = spaces.Home.id;
    folderParentId = suttonTrust.id;
    url = "https://us.suttontrust.com/how-to-apply/";
    position = 5101;
  };

  # Other Schemes (subfolder of Programmes)
  "Other Schemes" = otherSchemes;

  "In2STEM" = {
    id = "z4444444-4444-4444-8444-444444444454";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://in2scienceuk.org/our-programmes/in2stem/apply/";
    position = 5201;
  };

  "Future Leaders" = {
    id = "a5555555-5555-4555-8555-555555555565";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://www.futureleaders.uk/application";
    position = 5202;
  };

  "Young Asians" = {
    id = "b6666666-6666-4666-8666-666666666676";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://www.youngasians.org/";
    position = 5203;
  };

  "Jumpstart UK" = {
    id = "c7777777-7777-4777-8777-777777777787";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://www.jumpstart-uk.com/";
    position = 5204;
  };

  "Non-Trivial" = {
    id = "d8888888-8888-4888-8888-888888888898";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://www.non-trivial.org/";
    position = 5205;
  };

  "Kickstart Global" = {
    id = "e9999999-9999-4999-8999-999999999999";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://kickstartglobal.com/#welcome";
    position = 5206;
  };

  "Pathway CTM" = {
    id = "f0000000-0000-4000-8000-000000000010";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://pathwayctm.com/welcome/";
    position = 5207;
  };

  "Cohort 01" = {
    id = "g1111111-1111-4111-8111-111111111122";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://tally.so/r/mOpbxg";
    position = 5208;
  };

  "Youth Advisor Application" = {
    id = "h2222222-2222-4222-8222-222222222233";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://mission44.org/wp-content/uploads/2025/12/Youth-Advisor-Recruitment-Application-Pack-l-December-2025.pdf";
    position = 5209;
  };

  "20 Under 20" = {
    id = "i3333333-3333-4333-8333-333333333344";
    workspace = spaces.Home.id;
    folderParentId = otherSchemes.id;
    url = "https://meeting.springpod.com/20-under-20";
    position = 5210;
  };

  # Scholarships Folder
  "Scholarships" = scholarships;

  "Telford Scholarship" = {
    id = "k5555555-5555-4555-8555-555555555566";
    workspace = spaces.Home.id;
    folderParentId = scholarships.id;
    url = "https://rbt.org.uk/grants/telford-engineering-scholarship/";
    position = 6001;
  };

  "IET Future Talent" = {
    id = "l6666666-6666-4666-8666-666666666677";
    workspace = spaces.Home.id;
    folderParentId = scholarships.id;
    url = "https://www.theiet.org/impact-society/awards-prizes-and-scholarships/iet-future-talent-awards";
    position = 6002;
  };

  "AWE Defence Scholarship" = {
    id = "m7777777-7777-4777-8777-777777777788";
    workspace = spaces.Home.id;
    folderParentId = scholarships.id;
    url = "https://www.awe.co.uk/careers/early-careers/defence-undergraduate-scholarship-scheme/";
    position = 6003;
  };

  "Google Women in CS" = {
    id = "n8888888-8888-4888-8888-888888888899";
    workspace = spaces.Home.id;
    folderParentId = scholarships.id;
    url = "https://www.iie.org/programs/generationgoogle/generation-google-scholarship-for-women-in-computer-science-europe-middle-east-and-africa-emea/";
    position = 6004;
  };

  "Google Scholarship" = {
    id = "o9999999-9999-4999-8999-999999999991";
    workspace = spaces.Home.id;
    folderParentId = scholarships.id;
    url = "https://www.iie.org/programs/generationgoogle/";
    position = 6005;
  };

  "Semiconductor Talent Award" = {
    id = "p0000000-0000-4000-8000-000000000011";
    workspace = spaces.Home.id;
    folderParentId = scholarships.id;
    url = "https://www.ukesf.org/semiconductor-talent-award/";
    position = 6006;
  };

  "Born to Engineer Guide" = {
    id = "q1111111-1111-4111-8111-111111111123";
    workspace = spaces.Home.id;
    folderParentId = scholarships.id;
    url = "https://www.borntoengineer.com/resources/engineering-scholarship";
    position = 6007;
  };

  # Competitions Folder
  "Competitions" = competitions;

  # BIO (subfolder of Competitions)
  "BIO" = bio;

  "BIO Solutions GitHub" = {
    id = "t4444444-4444-4444-8444-444444444456";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    url = "https://github.com/tmncollins/BIO-Solutions";
    position = 7002;
  };

  "BIO Helper" = {
    id = "u5555555-5555-4555-8555-555555555567";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    url = "https://www.britishinformatics.org/bio1?problem=Short+Fuse";
    position = 7003;
  };

  "BIO 2025" = {
    id = "v6666666-6666-4666-8666-666666666678";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    url = "https://www.olympiad.org.uk/2025/index.html";
    position = 7004;
  };

  "Competitive Programming Guide" = {
    id = "w7777777-7777-4777-8777-777777777789";
    workspace = spaces.Home.id;
    folderParentId = bio.id;
    url = "https://www.geeksforgeeks.org/dsa/competitive-programming-a-complete-guide/";
    position = 7005;
  };

  # NASA Space Apps (subfolder of Competitions)
  "NASA Space Apps" = nasaSpaceApps;

  "Space Apps FAQ" = {
    id = "y9999999-9999-4999-8999-999999999992";
    workspace = spaces.Home.id;
    folderParentId = nasaSpaceApps.id;
    url = "https://www.spaceappschallenge.org/resources/-faq/";
    position = 7101;
  };

  "Space Apps London" = {
    id = "z0000000-0000-4000-8000-000000000012";
    workspace = spaces.Home.id;
    folderParentId = nasaSpaceApps.id;
    url = "https://www.spaceappschallenge.org/nasa-space-apps-2024/2024-local-events/london/?tab=details";
    position = 7102;
  };

  # Other Competitions (subfolder of Competitions)
  "Other Competitions" = otherCompetitions;

  "Pi Wars Rules" = {
    id = "b2222222-2222-4222-8222-222222222235";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://piwars.org/2024-disaster-zone/rules/";
    position = 7201;
  };

  "CREST Gold Award" = {
    id = "c3333333-3333-4333-8333-333333333346";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://www.crestawards.org/secondary-further-education/gold/";
    position = 7202;
  };

  "BAFTA YGD" = {
    id = "d4444444-4444-4444-8444-444444444457";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://www.bafta.org/programmes/young-game-designer/";
    position = 7203;
  };

  "BAFTA YGD Terms" = {
    id = "e5555555-5555-4555-8555-555555555568";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://www.bafta.org/wp-content/uploads/2024/11/2025-BAFTA-YGD-TCs-FINAL.pdf";
    position = 7204;
  };

  "Samsung Solve" = {
    id = "f6666666-6666-4666-8666-666666666679";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://www.samsung.com/uk/solvefortomorrow/";
    position = 7205;
  };

  "Cyber Leaders Challenge" = {
    id = "g7777777-7777-4777-8777-777777777790";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://cyberleaderschallenge.com/";
    position = 7206;
  };

  "UK Cyber Team" = {
    id = "h8888888-8888-4888-8888-888888888901";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://ukcyberteam.sans.org/";
    position = 7207;
  };

  "ICSC" = {
    id = "i9999999-9999-4999-8999-999999999993";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://icscompetition.org/en/index";
    position = 7208;
  };

  "IC Hack" = {
    id = "j0000000-0000-4000-8000-000000000013";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://ichack.org/";
    position = 7209;
  };

  "ICPC" = {
    id = "k1111111-1111-4111-8111-111111111125";
    workspace = spaces.Home.id;
    folderParentId = otherCompetitions.id;
    url = "https://icpc.global/";
    position = 7210;
  };

  # Incubators/Accelerators Folder
  "Incubators/Accelerators" = incubatorsAccelerators;

  "Entrepreneurs First" = {
    id = "m3333333-3333-4333-8333-333333333347";
    workspace = spaces.Home.id;
    folderParentId = incubatorsAccelerators.id;
    url = "https://apply.joinef.com/";
    position = 8001;
  };

  "The Residency" = {
    id = "n4444444-4444-4444-8444-444444444458";
    workspace = spaces.Home.id;
    folderParentId = incubatorsAccelerators.id;
    url = "https://www.livetheresidency.com/";
    position = 8002;
  };

  "93% Club" = {
    id = "o5555555-5555-4555-8555-555555555569";
    workspace = spaces.Home.id;
    folderParentId = incubatorsAccelerators.id;
    url = "https://www.93percent.club/students#typeform";
    position = 8003;
  };

  "Asian Arab Network" = {
    id = "p6666666-6666-4666-8666-666666666680";
    workspace = spaces.Home.id;
    folderParentId = incubatorsAccelerators.id;
    url = "https://www.linkedin.com/company/asianarabnetwork/about/";
    position = 8004;
  };

  # Technical/Programming Folder
  "Technical/Programming" = technicalProgramming;

  # Open Source (subfolder of Technical/Programming)
  "Open Source" = openSource;

  "Google Summer of Code" = {
    id = "s9999999-9999-4999-8999-999999999994";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://developers.google.com/open-source/gsoc/timeline";
    position = 9002;
  };

  "GSOC First Contact" = {
    id = "t0000000-0000-4000-8000-000000000014";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://google.github.io/gsocguides/student/making-first-contact";
    position = 9003;
  };

  "Google Open Source Blog" = {
    id = "u1111111-1111-4111-8111-111111111126";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://opensource.googleblog.com/";
    position = 9004;
  };

  "MLH Fellowship" = {
    id = "v2222222-2222-4222-8222-222222222237";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://fellowship.mlh.io/";
    position = 9005;
  };

  "Outreachy" = {
    id = "w3333333-3333-4333-8333-333333333348";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://www.outreachy.org/";
    position = 9006;
  };

  "Outreachy Guide" = {
    id = "x4444444-4444-4444-8444-444444444459";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://www.outreachy.org/docs/applicant/";
    position = 9007;
  };

  "KDE Mentorship" = {
    id = "y5555555-5555-4555-8555-555555555570";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://mentorship.kde.org/";
    position = 9008;
  };

  "Summer of Nix" = {
    id = "z6666666-6666-4666-8666-666666666681";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://github.com/ngi-nix/summer-of-nix";
    position = 9009;
  };

  "Hacktoberfest" = {
    id = "a7777777-7777-4777-8777-777777777792";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://hacktoberfest.com/";
    position = 9010;
  };

  "Codeheat" = {
    id = "b8888888-8888-4888-8888-888888888903";
    workspace = spaces.Home.id;
    folderParentId = openSource.id;
    url = "https://codeheat.org/";
    position = 9011;
  };

  # AI (subfolder of Technical/Programming)
  "AI" = ai;

  "AI Alignment" = {
    id = "d0000000-0000-4000-8000-000000000015";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://bluedot.org/courses/alignment?from_site=aisf";
    position = 9101;
  };

  "Technical AI Safety" = {
    id = "e1111111-1111-4111-8111-111111111127";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://web.miniextensions.com/9YX1i46qewCv5m17v8rl";
    position = 9102;
  };

  "BeyondAI" = {
    id = "f2222222-2222-4222-8222-222222222238";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://thinkingbeyond.education/beyondai/";
    position = 9103;
  };

  "BeyondAI Intro" = {
    id = "g3333333-3333-4333-8333-333333333349";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://thinkingbeyond.notion.site/BeyondAI-Introduction-to-AI-and-Research-Getting-ready-for-the-programme-edc0e088da424107a4a464be8b1de7c1";
    position = 9104;
  };

  "ThinkingBeyond" = {
    id = "h4444444-4444-4444-8444-444444444460";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://thinkingbeyond.education/#";
    position = 9105;
  };

  "Maths into AI" = {
    id = "i5555555-5555-4555-8555-555555555571";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://amsp.org.uk/event/4d462908-22e5-48f4-abea-b919d52eaa20/";
    position = 9106;
  };

  "Keep Future Human" = {
    id = "j6666666-6666-4666-8666-666666666682";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://keepthefuturehuman.ai/";
    position = 9107;
  };

  "Google AI Agents" = {
    id = "k7777777-7777-4777-8777-777777777793";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://rsvp.withgoogle.com/events/google-ai-agents-intensive_2025";
    position = 9108;
  };

  "Leaf Courses" = {
    id = "l8888888-8888-4888-8888-888888888904";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://leaf.courses/";
    position = 9109;
  };

  "AI Exam Tutor" = {
    id = "m9999999-9999-4999-8999-999999999996";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://ai-exam-tutor.web.app/loginSignUp.html";
    position = 9110;
  };

  "Medly AI" = {
    id = "n0000000-0000-4000-8000-000000000016";
    workspace = spaces.Home.id;
    folderParentId = ai.id;
    url = "https://medlyai.com/uk";
    position = 9111;
  };

  # NixOS (subfolder of Technical/Programming)
  "NixOS" = nixos;

  "NixOS Hardware" = {
    id = "p2222222-2222-4222-8222-222222222239";
    workspace = spaces.Home.id;
    folderParentId = nixos.id;
    url = "https://github.com/NixOS/nixos-hardware/tree/master/fydetab/duo";
    position = 9201;
  };

  "Disko" = {
    id = "q3333333-3333-4333-8333-333333333350";
    workspace = spaces.Home.id;
    folderParentId = nixos.id;
    url = "https://github.com/nix-community/disko";
    position = 9202;
  };

  "Denix" = {
    id = "r4444444-4444-4444-8444-444444444461";
    workspace = spaces.Home.id;
    folderParentId = nixos.id;
    url = "https://github.com/yunfachi/denix";
    position = 9203;
  };

  "NixOS BTRFS" = {
    id = "s5555555-5555-4555-8555-555555555572";
    workspace = spaces.Home.id;
    folderParentId = nixos.id;
    url = "https://www.reddit.com/r/NixOS/comments/1bqm7hv/do_you_use_btrfs/";
    position = 9204;
  };

  # Other Tools (subfolder of Technical/Programming)
  "Other Tools" = otherTools;

  "Prizm Programming" = {
    id = "u7777777-7777-4777-8777-777777777794";
    workspace = spaces.Home.id;
    folderParentId = otherTools.id;
    url = "https://prizm.cemetech.net/Prizm_Programming_Portal/";
    position = 9301;
  };

  "Add Timestamp Tool" = {
    id = "v8888888-8888-4888-8888-888888888905";
    workspace = spaces.Home.id;
    folderParentId = otherTools.id;
    url = "https://imageonline.co/add-date-timestamp-to-photo.php";
    position = 9302;
  };

  "Zen Browser Mods" = {
    id = "w9999999-9999-4999-8999-999999999997";
    workspace = spaces.Home.id;
    folderParentId = otherTools.id;
    url = "https://zen-browser.app/mods/d23733fa-983e-4680-8869-bf5b292d4fe6/";
    position = 9303;
  };

  "Zen Browser Reddit" = {
    id = "x0000000-0000-4000-8000-000000000017";
    workspace = spaces.Home.id;
    folderParentId = otherTools.id;
    url = "https://www.reddit.com/r/zen_browser/comments/1gyta8j/increase_font_size_of_the_tabs_name_and_the/";
    position = 9304;
  };

  "OSHub" = {
    id = "y1111111-1111-4111-8111-111111111129";
    workspace = spaces.Home.id;
    folderParentId = otherTools.id;
    url = "https://oshub.org/";
    position = 9305;
  };

  "US Graphics" = {
    id = "z2222222-2222-4222-8222-222222222240";
    workspace = spaces.Home.id;
    folderParentId = otherTools.id;
    url = "https://usgraphics.com/";
    position = 9306;
  };

  # ---- F1 in Schools Container Pins ----

  # F1 in Schools Folder
  "F1iS Resources" = f1isResources;

  "F1iS Enterprise Portfolio" = {
    id = "b4444444-4444-4444-8444-444444444462";
    workspace = spaces."F1 in Schools".id;
    folderParentId = f1isResources.id;
    url = "https://stolavesgrammarschool-my.sharepoint.com/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc=%7BBBBF0D93-E9E3-49AD-9F5B-B4F5ACF6B7F1%7D&file=F1iS%202023%20WF%20Honeycomb.pdf&action=default&mobileredirect=true";
    position = 10001;
  };

  "F1iS OneDrive" = {
    id = "c5555555-5555-4555-8555-555555555573";
    workspace = spaces."F1 in Schools".id;
    folderParentId = f1isResources.id;
    url = "https://stolavesgrammarschool-my.sharepoint.com/personal/aneeq_weerasinghe_saintolaves_net/Documents/Forms/All.aspx";
    position = 10002;
  };

  # ---- Programming Space Pins ----

  # RPI/Programming Folder
  "RPI/Programming" = rpiProgramming;

  # ---- Miscellaneous/Uncategorized ----
  # These didn't fit neatly into folders but were in your backup

  "Ivy League Guide" = {
    id = "e7777777-7777-4777-8777-777777777795";
    workspace = spaces.Home.id;
    url = "https://getintousunis.notion.site/How-to-get-into-the-Ivy-League-other-Elite-American-Universities-as-an-International-Student-ca44149dfa9240ab9ce32d9cae0b2e67";
    position = 12000;
    isEssential = false;
  };

  "A* Pathfinding" = {
    id = "f8888888-8888-4888-8888-888888888906";
    workspace = spaces.Home.id;
    url = "https://chatgpt.com/c/694ec075-34b8-832d-ad04-a61a7aaf7ddc";
    position = 12001;
    isEssential = false;
  };

  "Daniyaals Guides" = {
    id = "g9999999-9999-4999-8999-999999999998";
    workspace = spaces.Home.id;
    url = "https://daniyaalanawar.notion.site/Daniyaal-s-Guides-1da27b56e1808094b867dfb6723f314c";
    position = 12002;
    isEssential = false;
  };

  "I Want to Study Engineering" = {
    id = "h0000000-0000-4000-8000-000000000018";
    workspace = spaces.Home.id;
    url = "https://i-want-to-study-engineering.org/";
    position = 12003;
    isEssential = false;
  };

  "Tomorrows Engineers" = {
    id = "i1111111-1111-4111-8111-111111111130";
    workspace = spaces.Home.id;
    url = "https://www.tomorrowsengineers.org.uk/";
    position = 12004;
    isEssential = false;
  };

  "engNRICH" = {
    id = "j2222222-2222-4222-8222-222222222241";
    workspace = spaces.Home.id;
    url = "https://nrich.maths.org/engnrich";
    position = 12005;
    isEssential = false;
  };

  "OnePrep SAT" = {
    id = "k3333333-3333-4333-8333-333333333352";
    workspace = spaces.Home.id;
    url = "https://www.oneprep.xyz/";
    position = 12006;
    isEssential = false;
  };

  "GCSE Log" = {
    id = "l4444444-4444-4444-8444-444444444463";
    workspace = spaces.Home.id;
    url = "https://gcselog.com/";
    position = 12007;
    isEssential = false;
  };

  "IGCSE Centre" = {
    id = "m5555555-5555-4555-8555-555555555574";
    workspace = spaces.Home.id;
    url = "https://igcsecentre.com/about-igcse-centre/";
    position = 12008;
    isEssential = false;
  };

  "Bright Network" = {
    id = "n6666666-6666-4666-8666-666666666685";
    workspace = spaces.Home.id;
    url = "https://www.brightnetwork.co.uk/login/?next=/dashboard/";
    position = 12009;
    isEssential = false;
  };

  "Blackbullion" = {
    id = "o7777777-7777-4777-8777-777777777796";
    workspace = spaces.Home.id;
    url = "https://www.blackbullion.com/?status=uni-student";
    position = 12010;
    isEssential = false;
  };

  # ---- School/Admin ----

  "SIMS ID" = {
    id = "p8888888-8888-4888-8888-888888888907";
    workspace = spaces.Home.id;
    url = "https://sts.sims.co.uk/login?signin=70f83f94901d3f0c32f7774917d4b242";
    position = 13000;
    isEssential = false;
  };

  "Integral Maths" = {
    id = "q9999999-9999-4999-8999-999999999999";
    workspace = spaces.Home.id;
    url = "https://my.integralmaths.org/my/";
    position = 13001;
    isEssential = false;
  };

  "OneHive" = {
    id = "r0000000-0000-4000-8000-000000000019";
    workspace = spaces.Home.id;
    url = "https://tutorhive.co.uk/onehive/app/application/index";
    position = 13002;
    isEssential = false;
  };

  "Unifrog" = {
    id = "s1111111-1111-4111-8111-111111111131";
    workspace = spaces.Home.id;
    url = "https://www.unifrog.org/sign-in?return=%2fstudent%2fplacement";
    position = 13003;
    isEssential = false;
  };

  "MATLAB" = {
    id = "t2222222-2222-4222-8222-222222222242";
    workspace = spaces.Home.id;
    url = "https://matlab.mathworks.com/";
    position = 13004;
    isEssential = false;
  };

  "My Account" = {
    id = "u3333333-3333-4333-8333-333333333353";
    workspace = spaces.Home.id;
    url = "https://myaccount.microsoft.com/?ref=MeControl";
    position = 13005;
    isEssential = false;
  };

  # ---- Professional Resources ----

  "RAF Benson" = {
    id = "v4444444-4444-4444-8444-444444444464";
    workspace = spaces.Home.id;
    url = "https://www.raf.mod.uk/our-organisation/stations/raf-benson/contact-us/";
    position = 14000;
    isEssential = false;
  };

  "IMechE CV Guide" = {
    id = "w5555555-5555-4555-8555-555555555575";
    workspace = spaces.Home.id;
    url = "https://imeche.org/careers-education/careers-information/mechanical-engineering-careers-guide/write-a-great-cv";
    position = 14001;
    isEssential = false;
  };

  "Capgemini Work Experience" = {
    id = "x6666666-6666-4666-8666-666666666686";
    workspace = spaces.Home.id;
    url = "https://www.capgemini.com/gb-en/careers/capgemini-work-experience-2025/";
    position = 14002;
    isEssential = false;
  };

  "NPL Work Experience" = {
    id = "y7777777-7777-4777-8777-777777777797";
    workspace = spaces.Home.id;
    url = "https://www.npl.co.uk/careers/work-experience#Apply";
    position = 14003;
    isEssential = false;
  };

  "McLaren Careers" = {
    id = "z8888888-8888-4888-8888-888888888908";
    workspace = spaces.Home.id;
    url = "https://racingcareers.mclaren.com/o/early-careers-pathway-2024-4";
    position = 14004;
    isEssential = false;
  };
}

