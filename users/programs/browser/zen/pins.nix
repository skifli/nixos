# Pinned tabs with groups, folders, and container assignment
# Pins can be organized in folders and assigned to specific containers/spaces.
#
# ⚠ Only if using pins or pinsForce: close Zen before home-manager switch
# (activation script needs exclusive access to modify zen-sessions.jsonlz4)
let
  containers = import ./containers.nix;
  spaces = import ./spaces.nix;

  # --------------------------------------------------------------------------
  # Folders – IDs derived from their positions (1..83)
  # --------------------------------------------------------------------------
  folderSpecs = {
    space-personal_container-personal_AI = {
      id = "f0000007-0000-4000-8000-000000000007";
      position = 7;
      workspace = spaces.Personal.id;
      container = containers.Personal.id;
    };
    space-personal_container-personal_AI_RateLimiting = {
      id = "f0000008-0000-4000-8000-000000000008";
      parent = "space-personal_container-personal_AI";
      position = 8;
      workspace = spaces.Personal.id;
      container = containers.Personal.id;
    };
    space-personal_container-personal_Arkwright = {
      id = "f0000016-0000-4000-8000-000000000016";
      position = 16;
      workspace = spaces.Personal.id;
      container = containers.Personal.id;
    };
    space-personal_container-personal_Arkwright_Photos = {
      id = "f0000017-0000-4000-8000-000000000017";
      parent = "space-personal_container-personal_Arkwright";
      position = 17;
      workspace = spaces.Personal.id;
      container = containers.Personal.id;
    };
    space-school_container-school_ESAT = {
      id = "f0000030-0000-4000-8000-000000000030";
      position = 30;
      workspace = spaces.School.id;
      container = containers.School.id;
    };
    space-school_container-school_CSNEA = {
      id = "f0000043-0000-4000-8000-000000000043";
      position = 43;
      workspace = spaces.School.id;
      container = containers.School.id;
    };
    space-stemracing_container-stemracing_Tools = {
      id = "f0000055-0000-4000-8000-000000000055";
      position = 55;
      workspace = spaces."Stem Racing".id;
      container = containers."Stem Racing".id;
    };
  };

  folderIds = builtins.mapAttrs (_: spec: spec.id) folderSpecs;

  mkFolder = spec:
    {
      inherit (spec) id position workspace container;
      isGroup = true;
      isFolderCollapsed = true;
      editedTitle = true;
    }
    // (
      if spec ? parent
      then {folderParentId = folderIds.${spec.parent};}
      else {}
    );

  folders = builtins.mapAttrs (_: mkFolder) folderSpecs;

  # --------------------------------------------------------------------------
  # Pins – IDs derived from their positions (1..83)
  # --------------------------------------------------------------------------
  pinSpecs = {
    # ----- Personal Space – top‑level (1‑6) -----
    space-personal_container-personal_Spotify = {
      id = "a0000001-0000-4000-8000-000000000001";
      url = "https://open.spotify.com/playlist/0wBpBFi0ox6sKqF2B7kr9E";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 1;
    };
    space-personal_container-personal_Discord = {
      id = "a0000002-0000-4000-8000-000000000002";
      url = "https://discord.com/channels/@me";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 2;
    };
    space-personal_container-personal_ActivityWatch = {
      id = "a0000003-0000-4000-8000-000000000003";
      url = "http://pifi:5600/#/activity/lyra/view/";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 3;
    };
    space-personal_container-personal_DeepSeek = {
      id = "a0000004-0000-4000-8000-000000000004";
      url = "https://chat.deepseek.com";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 4;
    };
    space-personal_container-personal_GoogleAIStudio = {
      id = "a0000005-0000-4000-8000-000000000005";
      url = "https://aistudio.google.com/prompts/new_chat";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 5;
    };
    space-personal_container-personal_Kimi = {
      id = "a0000006-0000-4000-8000-000000000006";
      url = "https://www.kimi.com";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 6;
    };

    # ----- Rate Limiting folder children (9‑11) -----
    space-personal_container-personal_AI_RateLimiting_CopilotUsage = {
      id = "a0000009-0000-4000-8000-000000000009";
      url = "https://github.com/settings/billing";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_AI_RateLimiting";
      position = 9;
    };
    space-personal_container-personal_AI_RateLimiting_GeminiAPIRateLimit = {
      id = "a0000010-0000-4000-8000-000000000010";
      url = "https://aistudio.google.com/rate-limit?timeRange=last-90-days";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_AI_RateLimiting";
      position = 10;
    };
    space-personal_container-personal_AI_RateLimiting_GeminiAPIUsage = {
      id = "a0000011-0000-4000-8000-000000000011";
      url = "https://aistudio.google.com/usage?timeRange=last-90-days";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_AI_RateLimiting";
      position = 11;
    };

    # ----- AI folder children (12‑15) -----
    space-personal_container-personal_AI_Claude = {
      id = "a0000012-0000-4000-8000-000000000012";
      url = "https://claude.ai/new";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_AI";
      position = 12;
    };
    space-personal_container-personal_AI_GoogleGemini = {
      id = "a0000013-0000-4000-8000-000000000013";
      url = "https://gemini.google.com/app";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_AI";
      position = 13;
    };
    space-personal_container-personal_AI_Perplexity = {
      id = "a0000014-0000-4000-8000-000000000014";
      url = "https://www.perplexity.ai/";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_AI";
      position = 14;
    };
    space-personal_container-personal_AI_Maple = {
      id = "a0000015-0000-4000-8000-000000000015";
      url = "https://trymaple.ai/";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_AI";
      position = 15;
    };

    # ----- Photos folder children (18‑19) -----
    space-personal_container-personal_Arkwright_Photos_Gallery = {
      id = "a0000018-0000-4000-8000-000000000018";
      url = "https://gallery.squireandsquire.co.uk/-arkwrightengineeringscholarshipsnetworkingeventsouth/gallery";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_Arkwright_Photos";
      position = 18;
    };
    space-personal_container-personal_Arkwright_Photos_GeneralPhotography = {
      id = "a0000019-0000-4000-8000-000000000019";
      url = "https://gallery.squireandsquire.co.uk/-arkwrightengineeringeventsouthgeneralphotography/";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_Arkwright_Photos";
      position = 19;
    };

    # ----- Arkwright folder children (20‑22) -----
    space-personal_container-personal_Arkwright_sfgMentorNet = {
      id = "a0000020-0000-4000-8000-000000000020";
      url = "https://smallpeicetrust.sfgmentornet.com/spa/";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_Arkwright";
      position = 20;
    };
    space-personal_container-personal_Arkwright_SmallpieceEvents = {
      id = "a0000021-0000-4000-8000-000000000021";
      url = "https://www.smallpeicetrust.org.uk/events-calendar/?course_type=110";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_Arkwright";
      position = 21;
    };
    space-personal_container-personal_Arkwright_WCSIMLogin = {
      id = "a0000022-0000-4000-8000-000000000022";
      url = "https://wcsim.co.uk/wp-login.php";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "space-personal_container-personal_Arkwright";
      position = 22;
    };

    # ----- Personal misc (23‑25) -----
    space-personal_container-personal_LastFM = {
      id = "a0000023-0000-4000-8000-000000000023";
      url = "https://www.last.fm/user/skifli";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      position = 23;
    };
    space-personal_container-personal_FMHY = {
      id = "a0000024-0000-4000-8000-000000000024";
      url = "https://fmhy.net/";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      position = 24;
    };
    space-personal_container-personal_Converter = {
      id = "a0000025-0000-4000-8000-000000000025";
      url = "https://p2r3.github.io/convert/";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      position = 25;
    };

    # ----- School Space – top‑level (26‑29) -----
    space-school_container-school_UCAS = {
      id = "a0000026-0000-4000-8000-000000000026";
      url = "https://accounts.ucas.com/Account/Login";
      container = containers.School.id;
      workspace = spaces.School.id;
      isEssential = true;
      position = 26;
    };
    space-school_container-school_UATUK = {
      id = "a0000027-0000-4000-8000-000000000027";
      url = "https://uatuk.useclarus.com/login?forward_url=%2F";
      container = containers.School.id;
      workspace = spaces.School.id;
      isEssential = true;
      position = 27;
    };
    space-school_container-school_Integral = {
      id = "a0000028-0000-4000-8000-000000000028";
      url = "https://my.integralmaths.org/my/";
      container = containers.School.id;
      workspace = spaces.School.id;
      isEssential = true;
      position = 28;
    };
    space-school_container-school_OneDrive = {
      id = "a0000029-0000-4000-8000-000000000029";
      url = "https://stolavesgrammarschool-my.sharepoint.com/my";
      container = containers.School.id;
      workspace = spaces.School.id;
      isEssential = true;
      position = 29;
    };

    # ----- ESAT folder children (31‑42) -----
    space-school_container-school_ESAT_Prepare = {
      id = "a0000031-0000-4000-8000-000000000031";
      url = "https://esat-tmua.ac.uk/prepare/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 31;
    };
    space-school_container-school_ESAT_Specification = {
      id = "a0000032-0000-4000-8000-000000000032";
      url = "https://uat-wp.s3.eu-west-2.amazonaws.com/wp-content/uploads/2025/04/30103004/ESAT_Content_Specification_April2025.pdf";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 32;
    };
    space-school_container-school_ESAT_Guide = {
      id = "a0000033-0000-4000-8000-000000000033";
      url = "https://exams.ninja/esat/guide/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 33;
    };
    space-school_container-school_ENGAA-NSAA-PPQs = {
      id = "a0000034-0000-4000-8000-000000000034";
      url = "https://esat-tmua.ac.uk/esat-preparation-materials/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 34;
    };
    space-school_container-school_ECAA-PPQs = {
      id = "a0000035-0000-4000-8000-000000000035";
      url = "https://www.physicsandmathstutor.com/admissions/ecaa/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 35;
    };
    space-school_container-school_BMAT-PPQs = {
      id = "a0000036-0000-4000-8000-000000000036";
      url = "https://www.physicsandmathstutor.com/admissions/bmat/papers/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 36;
    };
    space-school_container-school_PAT-PPQs = {
      id = "a0000037-0000-4000-8000-000000000037";
      url = "https://www.physicsandmathstutor.com/admissions/pat/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 37;
    };
    space-school_container-school_MAT-PPQs = {
      id = "a0000038-0000-4000-8000-000000000038";
      url = "https://www.physicsandmathstutor.com/admissions/mat/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 38;
    };
    space-school_container-school_SMC-PPQs = {
      id = "a0000039-0000-4000-8000-000000000039";
      url = "https://mathsaurus.com/senior-maths-challenge-grade-boundaries/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 39;
    };
    # TMUA PPQs – PMT (position 40)
    space-school_container-school_TMUA_PMT = {
      id = "a0000040-0000-4000-8000-000000000040";
      url = "https://www.physicsandmathstutor.com/admissions/tmua/";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 40;
    };
    # TMUA Preparation – Tyler Tutoring (position 41)
    space-school_container-school_TMUA_Tyler = {
      id = "a0000041-0000-4000-8000-000000000041";
      url = "https://www.tylertutoring.com/tmua";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 41;
    };
    space-school_container-school_Isaac-Tests = {
      id = "a0000042-0000-4000-8000-000000000042";
      url = "https://isaacscience.org/practice_tests";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_ESAT";
      position = 42;
    };

    # ----- CS NEA folder children (44‑47) -----
    space-school_container-school_CSNEA-MS = {
      id = "a0000044-0000-4000-8000-000000000044";
      url = "file:///home/ami/Downloads/CS%20NEA/MS.pdf";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_CSNEA";
      position = 44;
    };
    space-school_container-school_CSNEA-Exemplar = {
      id = "a0000045-0000-4000-8000-000000000045";
      url = "file:///home/ami/Downloads/CS%20NEA/Analysis/Candidate%203%20-%20(68%20out%20of%2070)%20-%20Project%20writeup.pdf";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_CSNEA";
      position = 45;
    };
    space-school_container-school_CSNEA-AMNEA = {
      id = "a0000046-0000-4000-8000-000000000046";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/g/personal/abhinav_malladi_saintolaves_net/IQBTX4wdlMizQ6BDfHNdYl4BAfWsj3FsxujDWVvcrTfngGs?e=dTbjcZile:///home/ami/Downloads/CS%20NEA/Analysis/NEA%20Guide.pdf";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_CSNEA";
      position = 46;
    };
    space-school_container-school_CSNEA-MQNEA = {
      id = "a0000047-0000-4000-8000-000000000047";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/g/personal/michael_qu_saintolaves_net/IQDWHgmXJtnYSqyO-v_8heEwAX9R8BZscq4OtrE2GEDsRb4?e=lvEOdg";
      container = containers.School.id;
      workspace = spaces.School.id;
      folder = "space-school_container-school_CSNEA";
      position = 47;
    };

    # ----- School misc (48‑52) -----
    space-school_container-school_MSAccount = {
      id = "a0000048-0000-4000-8000-000000000048";
      url = "https://myaccount.microsoft.com/";
      container = containers.School.id;
      workspace = spaces.School.id;
      position = 48;
    };
    space-school_container-school_SIMSStudent = {
      id = "a0000049-0000-4000-8000-000000000049";
      url = "https://www.sims-student.co.uk/#!/schools/deb7228f-ad38-4678-8692-12ccf6422749/home";
      container = containers.School.id;
      workspace = spaces.School.id;
      position = 49;
    };
    space-school_container-school_SOUN = {
      id = "a0000050-0000-4000-8000-000000000050";
      url = "https://olavesunofficialnews.wordpress.com/";
      container = containers.School.id;
      workspace = spaces.School.id;
      position = 50;
    };
    space-school_container-school_ExamQ = {
      id = "a0000051-0000-4000-8000-000000000051";
      url = "https://www.examq.co.uk/qualification/ahtaxu";
      container = containers.School.id;
      workspace = spaces.School.id;
      position = 51;
    };
    space-school_container-school_XtremePapers-Mathematics = {
      id = "a0000052-0000-4000-8000-000000000052";
      url = "https://papers.xtremepape.rs/index.php?dirpath=./Edexcel/Advanced+Level/Mathematics/&order=0";
      container = containers.School.id;
      workspace = spaces.School.id;
      position = 52;
    };

    # ----- Stem Racing Space (53‑78) -----
    # top‑level (53‑54)
    space-stemracing_container-stemracing_OneDrive = {
      id = "a0000053-0000-4000-8000-000000000053";
      url = "https://stolavesgrammarschool-my.sharepoint.com/my?id=%2Fpersonal%2Faneeq_weerasinghe_saintolaves_net%2FDocuments%2FF1%20in%20Schools&viewid=8d376b40-6297-42a5-9a9e-fa5720076727";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      isEssential = true;
      position = 53;
    };
    space-stemracing_container-stemracing_Todo = {
      id = "a0000054-0000-4000-8000-000000000054";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc={2B9C1F64-460A-4570-B879-72AF0C74A5F0}&file=Todo.docx&action=default&mobileredirect=true";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      isEssential = true;
      position = 54;
    };

    # Tools folder children (56‑71)
    space-stemracing_container-stemracing_Tools_BauhausPattern = {
      id = "a0000056-0000-4000-8000-000000000056";
      url = "https://bauhaus-pattern.netlify.app/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 56;
    };
    space-stemracing_container-stemracing_Tools_JPGGlitch = {
      id = "a0000057-0000-4000-8000-000000000057";
      url = "https://snorpey.github.io/jpg-glitch/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 57;
    };
    space-stemracing_container-stemracing_Tools_MoshPro = {
      id = "a0000058-0000-4000-8000-000000000058";
      url = "https://moshpro.app/lite/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 58;
    };
    space-stemracing_container-stemracing_Tools_BeFunky = {
      id = "a0000059-0000-4000-8000-000000000059";
      url = "https://www.befunky.com/create/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 59;
    };
    space-stemracing_container-stemracing_Tools_EndlessTools = {
      id = "a0000060-0000-4000-8000-000000000060";
      url = "https://endlesstools.io/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 60;
    };
    space-stemracing_container-stemracing_Tools_Tooools = {
      id = "a0000061-0000-4000-8000-000000000061";
      url = "https://www.tooooools.app/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 61;
    };
    space-stemracing_container-stemracing_Tools_ShadersPaper = {
      id = "a0000062-0000-4000-8000-000000000062";
      url = "https://shaders.paper.design/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 62;
    };
    space-stemracing_container-stemracing_Tools_EffectApp = {
      id = "a0000063-0000-4000-8000-000000000063";
      url = "https://effect.app/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 63;
    };
    space-stemracing_container-stemracing_Tools_PixelCrash = {
      id = "a0000064-0000-4000-8000-000000000064";
      url = "https://www.pixelcrash.xyz/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 64;
    };
    space-stemracing_container-stemracing_Tools_CodePenGlitch = {
      id = "a0000065-0000-4000-8000-000000000065";
      url = "https://codepen.io/sabosugi/full/bNegbmy";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 65;
    };
    space-stemracing_container-stemracing_Tools_GrainRad = {
      id = "a0000066-0000-4000-8000-000000000066";
      url = "https://grainrad.com/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 66;
    };
    space-stemracing_container-stemracing_Tools_JitterVideo = {
      id = "a0000067-0000-4000-8000-000000000067";
      url = "https://jitter.video/templates/social-media/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 67;
    };
    space-stemracing_container-stemracing_Tools_DitherIt = {
      id = "a0000068-0000-4000-8000-000000000068";
      url = "https://ditheritv3.netlify.app/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 68;
    };
    space-stemracing_container-stemracing_Tools_3DGifMaker = {
      id = "a0000069-0000-4000-8000-000000000069";
      url = "https://www.3dgifmaker.com/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 69;
    };
    space-stemracing_container-stemracing_Tools_PhotoGradient = {
      id = "a0000070-0000-4000-8000-000000000070";
      url = "https://photogradient.com/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 70;
    };
    space-stemracing_container-stemracing_Tools_SpaceType = {
      id = "a0000071-0000-4000-8000-000000000071";
      url = "https://spacetypegenerator.com/";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      folder = "space-stemracing_container-stemracing_Tools";
      position = 71;
    };

    # Stem Racing misc (72‑78)
    space-stemracing_container-stemracing_SustainabilityAndInnovations = {
      id = "a0000072-0000-4000-8000-000000000072";
      url = "https://stolavesgrammarschool-my.sharepoint.com/my?id=%2Fpersonal%2Faneeq%5Fweerasinghe%5Fsaintolaves%5Fnet%2FDocuments%2FF1%20in%20Schools%2FF1%20in%20Schools%202025%20%2D%202026%2FSustainability%20%26%20Innovations&viewid=8d376b40%2D6297%2D42a5%2D9a9e%2Dfa5720076727&login_hint=Aneeq%2EWeerasinghe%40saintolaves%2Enet&source=waffle";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      position = 72;
    };
    space-stemracing_container-stemracing_EnterprisePortfolioFeedback = {
      id = "a0000073-0000-4000-8000-000000000073";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc=%7B93B23519-4267-45C9-B768-BAC9C6DCF5CA%7D&file=Enterprise%20Portfolio%20Feedback.docx&action=default&mobileredirect=true";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      position = 73;
    };
    space-stemracing_container-stemracing_WFComboMain = {
      id = "a0000074-0000-4000-8000-000000000074";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc=%7BD606DF8E-8F7A-43E1-89EB-8D7C65A37F98%7D&file=WF%20Combo%20Main.docx&action=default&mobileredirect=true";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      position = 74;
    };
    space-stemracing_container-stemracing_WFComboDigital-SocialMedia = {
      id = "a0000075-0000-4000-8000-000000000075";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc=%7B549154C4-1788-44FC-AC6E-F76636901FBB%7D&file=WF%20Combo%20Digital-Social%20Media.docx&action=default&mobileredirect=true";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      position = 75;
    };
    space-stemracing_container-stemracing_WFComboEnterprise = {
      id = "a0000076-0000-4000-8000-000000000076";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc=%7B88D31E37-9CEF-48E5-BC0F-9451C01A2F73%7D&file=WF%20Combo%20Enterprise.docx&action=default&mobileredirect=true";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      position = 76;
    };
    space-stemracing_container-stemracing_WFComboPitDisplay = {
      id = "a0000077-0000-4000-8000-000000000077";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc=%7B5655B289-D378-4A78-B8AD-E29325EFE048%7D&file=WF%20Combo%20Pit%20Display.docx&action=default&mobileredirect=true";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      position = 77;
    };
    space-stemracing_container-stemracing_WFComboVerbalPresentation = {
      id = "a0000078-0000-4000-8000-000000000078";
      url = "https://stolavesgrammarschool-my.sharepoint.com/:w:/r/personal/aneeq_weerasinghe_saintolaves_net/_layouts/15/Doc.aspx?sourcedoc=%7BEE02AA17-BB54-464D-BAB7-EB87B471A26C%7D&file=WF%20Combo%20Verbal%20Pres.docx&action=default&mobileredirect=true";
      container = containers."Stem Racing".id;
      workspace = spaces."Stem Racing".id;
      position = 78;
    };

    # ----- Computing Space (79‑83) -----
    space-computing_container-personal_RPIConnect = {
      id = "a0000079-0000-4000-8000-000000000079";
      url = "https://connect.raspberrypi.com/devices";
      container = containers.Personal.id;
      workspace = spaces.Computing.id;
      position = 79;
    };
    space-computing_container-personal_pifiSS = {
      id = "a0000080-0000-4000-8000-000000000080";
      url = "https://connect.raspberrypi.com/devices/0ddb991f-8e0d-4dee-853c-64693b5acde7/screen-sharing-session/";
      container = containers.Personal.id;
      workspace = spaces.Computing.id;
      position = 80;
    };
    space-computing_container-personal_pistorSS = {
      id = "a0000081-0000-4000-8000-000000000081";
      url = "https://connect.raspberrypi.com/devices/7af88ae4-a215-4508-8aa1-b757e8be6b0d/screen-sharing-session";
      container = containers.Personal.id;
      workspace = spaces.Computing.id;
      position = 81;
    };
    space-computing_container-personal_Tailscale = {
      id = "a0000082-0000-4000-8000-000000000082";
      url = "https://login.tailscale.com/admin/machines";
      container = containers.Personal.id;
      workspace = spaces.Computing.id;
      position = 82;
    };
    space-computing_container-personal_selfhst = {
      id = "a0000083-0000-4000-8000-000000000083";
      url = "https://selfh.st/apps/";
      container = containers.Personal.id;
      workspace = spaces.Computing.id;
      position = 83;
    };
  };

  # --------------------------------------------------------------------------
  # mkPin – adds folderParentId if a folder is referenced
  # --------------------------------------------------------------------------
  mkPin = spec:
    {
      inherit (spec) id position url container workspace;
    }
    // (
      if spec ? folder
      then {folderParentId = folderIds.${spec.folder};}
      else {}
    )
    // (
      if spec ? isEssential
      then {inherit (spec) isEssential;}
      else {}
    );

  pins = builtins.mapAttrs (_: mkPin) pinSpecs;
in {
  # Personal Space
  "Spotify" = pins.space-personal_container-personal_Spotify;
  "Discord" = pins.space-personal_container-personal_Discord;
  "ActivityWatch" = pins.space-personal_container-personal_ActivityWatch;
  "DeepSeek" = pins.space-personal_container-personal_DeepSeek;
  "Google AI Studio" = pins.space-personal_container-personal_GoogleAIStudio;
  "Kimi" = pins.space-personal_container-personal_Kimi;

  "AI" = folders.space-personal_container-personal_AI;
  "Rate Limiting" = folders.space-personal_container-personal_AI_RateLimiting;
  "Copilot Usage" = pins.space-personal_container-personal_AI_RateLimiting_CopilotUsage;
  "Gemini API Rate Limit" = pins.space-personal_container-personal_AI_RateLimiting_GeminiAPIRateLimit;
  "Gemini API Usage" = pins.space-personal_container-personal_AI_RateLimiting_GeminiAPIUsage;
  "Claude" = pins.space-personal_container-personal_AI_Claude;
  "Google Gemini" = pins.space-personal_container-personal_AI_GoogleGemini;
  "Perplexity" = pins.space-personal_container-personal_AI_Perplexity;
  "Maple" = pins.space-personal_container-personal_AI_Maple;

  "Arkwright" = folders.space-personal_container-personal_Arkwright;
  "Photos" = folders.space-personal_container-personal_Arkwright_Photos;
  "Gallery" = pins.space-personal_container-personal_Arkwright_Photos_Gallery;
  "General Photography" = pins.space-personal_container-personal_Arkwright_Photos_GeneralPhotography;
  "MentorNet" = pins.space-personal_container-personal_Arkwright_sfgMentorNet;
  "Smallpiece Events" = pins.space-personal_container-personal_Arkwright_SmallpieceEvents;
  "WCSIM Login" = pins.space-personal_container-personal_Arkwright_WCSIMLogin;

  "LastFM" = pins.space-personal_container-personal_LastFM;
  "FMHY" = pins.space-personal_container-personal_FMHY;
  "Converter" = pins.space-personal_container-personal_Converter;

  # School Space
  "UCAS" = pins.space-school_container-school_UCAS;
  "UATUK" = pins.space-school_container-school_UATUK;
  "Integral" = pins.space-school_container-school_Integral;
  "OneDrive" = pins.space-school_container-school_OneDrive;

  "ESAT" = folders.space-school_container-school_ESAT;
  "Prepare" = pins.space-school_container-school_ESAT_Prepare;
  "Specification" = pins.space-school_container-school_ESAT_Specification;
  "Guide" = pins.space-school_container-school_ESAT_Guide;
  "ENGAA/NSAA PPQs" = pins.space-school_container-school_ENGAA-NSAA-PPQs;
  "ECAA PPQs" = pins.space-school_container-school_ECAA-PPQs;
  "BMAT PPQs" = pins.space-school_container-school_BMAT-PPQs;
  "PAT PPQs" = pins.space-school_container-school_PAT-PPQs;
  "MAT PPQs" = pins.space-school_container-school_MAT-PPQs;
  "SMC PPQs" = pins.space-school_container-school_SMC-PPQs;
  "TMUA PPQs" = pins.space-school_container-school_TMUA_PMT;
  "TMUA Preparation" = pins.space-school_container-school_TMUA_Tyler;
  "Isaac Tests" = pins.space-school_container-school_Isaac-Tests;

  "CS NEA" = folders.space-school_container-school_CSNEA;
  "Mark Scheme" = pins.space-school_container-school_CSNEA-MS;
  "Exemplar NEA" = pins.space-school_container-school_CSNEA-Exemplar;
  "AM NEA" = pins.space-school_container-school_CSNEA-AMNEA;
  "MQ NEA" = pins.space-school_container-school_CSNEA-MQNEA;

  "Microsoft Account" = pins.space-school_container-school_MSAccount;
  "SIMS Student" = pins.space-school_container-school_SIMSStudent;
  "SOUN" = pins.space-school_container-school_SOUN;
  "ExamQ" = pins.space-school_container-school_ExamQ;
  "Xtreme Papers - Mathematics" = pins.space-school_container-school_XtremePapers-Mathematics;

  # "Stem Racing" Space
  "SR OneDrive" = pins.space-stemracing_container-stemracing_OneDrive;
  "Todo" = pins.space-stemracing_container-stemracing_Todo;
  "Tools" = folders.space-stemracing_container-stemracing_Tools;
  "Bauhaus Pattern" = pins.space-stemracing_container-stemracing_Tools_BauhausPattern;
  "JPG Glitch" = pins.space-stemracing_container-stemracing_Tools_JPGGlitch;
  "Mosh Pro Lite" = pins.space-stemracing_container-stemracing_Tools_MoshPro;
  "BeFunky" = pins.space-stemracing_container-stemracing_Tools_BeFunky;
  "Endless Tools" = pins.space-stemracing_container-stemracing_Tools_EndlessTools;
  "Tooools" = pins.space-stemracing_container-stemracing_Tools_Tooools;
  "Shaders Paper" = pins.space-stemracing_container-stemracing_Tools_ShadersPaper;
  "Effect App" = pins.space-stemracing_container-stemracing_Tools_EffectApp;
  "Pixel Crash" = pins.space-stemracing_container-stemracing_Tools_PixelCrash;
  "CodePen Glitch" = pins.space-stemracing_container-stemracing_Tools_CodePenGlitch;
  "Grain Rad" = pins.space-stemracing_container-stemracing_Tools_GrainRad;
  "Jitter Video" = pins.space-stemracing_container-stemracing_Tools_JitterVideo;
  "Dither It" = pins.space-stemracing_container-stemracing_Tools_DitherIt;
  "3D GIF Maker" = pins.space-stemracing_container-stemracing_Tools_3DGifMaker;
  "Photo Gradient" = pins.space-stemracing_container-stemracing_Tools_PhotoGradient;
  "Space Type Generator" = pins.space-stemracing_container-stemracing_Tools_SpaceType;

  "Sustainability & Innovations" = pins.space-stemracing_container-stemracing_SustainabilityAndInnovations;
  "Enterprise Portfolio Feedback" = pins.space-stemracing_container-stemracing_EnterprisePortfolioFeedback;
  "WF Combo Main" = pins.space-stemracing_container-stemracing_WFComboMain;
  "WF Combo Digital/Social Media" = pins.space-stemracing_container-stemracing_WFComboDigital-SocialMedia;
  "WF Combo Enterprise" = pins.space-stemracing_container-stemracing_WFComboEnterprise;
  "WF Combo Pit Display" = pins.space-stemracing_container-stemracing_WFComboPitDisplay;
  "WF Combo Verbal Presentation" = pins.space-stemracing_container-stemracing_WFComboVerbalPresentation;

  # Computing Space
  "RPI Connect" = pins.space-computing_container-personal_RPIConnect;
  "pifi Screen Sharing" = pins.space-computing_container-personal_pifiSS;
  "pistor Screen Sharing" = pins.space-computing_container-personal_pistorSS;
  "Tailscale" = pins.space-computing_container-personal_Tailscale;
  "Selfhosted Apps" = pins.space-computing_container-personal_selfhst;
}
