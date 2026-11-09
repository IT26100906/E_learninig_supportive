/* LearnHub - course catalogue for the UI pages.
   Every learner level (Child / Grade 1-11 / A/L / Undergraduate) sees the courses that fit THEM.
   Admins see every course. Replace this file with data from your Course servlet / database later. */
(function (LH) {
  var G = ['linear-gradient(135deg,#2563eb,#38bdf8)', 'linear-gradient(135deg,#059669,#34d399)', 'linear-gradient(135deg,#7c3aed,#c084fc)', 'linear-gradient(135deg,#d97706,#fbbf24)',
           'linear-gradient(135deg,#dc2626,#f87171)', 'linear-gradient(135deg,#0891b2,#22d3ee)', 'linear-gradient(135deg,#16a34a,#86efac)', 'linear-gradient(135deg,#ec4899,#f9a8d4)'];
  var POOL = {
    CHILD:     {t: ['Ms. Malsha Gomes', 'Ms. Dilrukshi Perera', 'Mr. Chamath Silva', 'Ms. Nethmi Fernando'], role: 'Early childhood teacher', lang: 'Sinhala / English / Tamil',
                sch: ['Sat, 9.00 am - 10.00 am', 'Mon & Wed, 4.00 pm - 4.45 pm', 'Sun, 10.00 am - 11.00 am'], reqs: ['Crayons, colour pencils and paper', 'A parent or guardian nearby']},
    SCHOOL:    {t: ['Mr. Kamal Fonseka', 'Ms. Hiruni Dias', 'Mrs. Sandya Wijesekara', 'Mr. Rohan Abeysekara'], role: 'Senior school teacher', lang: 'Sinhala / English',
                sch: ['Sat, 2.00 pm - 4.00 pm', 'Tue & Thu, 5.00 pm - 6.30 pm', 'Sun, 8.00 am - 10.00 am'], reqs: ['Exercise book and pens', 'School syllabus textbook']},
    AL:        {t: ['Mr. Sampath Rajapaksha', 'Dr. Lakmal Weerakoon', 'Ms. Priyanka Jayasuriya', 'Mr. Thilina Bandara'], role: 'A/L subject specialist, 15+ years', lang: 'Sinhala / English',
                sch: ['Sun, 8.00 am - 12.00 pm', 'Sat, 1.00 pm - 5.00 pm', 'Wed & Fri, 5.30 pm - 7.30 pm'], reqs: ['Passed O/L examination', 'Registered for the A/L stream']},
    UNDERGRAD: {t: ['Dr. Ruwan Perera', 'Prof. Nuwan Jayawardena', 'Ms. Chamari Weerasinghe', 'Dr. Anusha Silva', 'Dr. Lakshan Amarasinghe', 'Prof. Shamila Herath', 'Mr. Dinesh Kodikara'], role: 'University lecturer & industry expert', lang: 'English',
                sch: ['Mon & Wed, 6.30 pm - 8.30 pm', 'Sat, 9.00 am - 12.00 pm', 'Tue & Thu, 7.00 pm - 9.00 pm'], reqs: ['Laptop with internet', 'Enrolled in a degree or diploma programme']}
  };
  /* degree (sign-up dropdown) -> course groups. Keep in sync with StudentLevel.UG_DEGREES (Java). */
  var DEGREES = {"BSc (Hons) in Information Technology": ["cs"],"BSc (Hons) in Computer Science": ["cs"],"BSc (Hons) in Software Engineering": ["cs","se"],"BSc (Hons) in Data Science": ["cs","ds"],"BSc (Hons) in Cyber Security": ["cs","sec"],"BSc (Hons) in Information Systems": ["cs","is"],"BSc in Business Management": ["biz"],"BBA in Accounting & Finance": ["biz","acc"],"BSc in Marketing Management": ["biz","mkt"],"BSc in Human Resource Management": ["biz","hr"],"BSc in Banking & Finance": ["biz","bank"],"BSc Eng (Hons) in Civil Engineering": ["eng","civil"],"BSc Eng (Hons) in Electrical & Electronic Engineering": ["eng","elec"],"BSc Eng (Hons) in Mechanical Engineering": ["eng","mech"],"BSc Eng (Hons) in Mechatronics Engineering": ["eng","mecha"],"BSc (Hons) in Quantity Surveying": ["qs"],"BSc (Hons) in Architecture": ["arch"],"BSc in Physical Science": ["sci","phys"],"BSc in Biological Science": ["sci","bio"],"BSc in Chemistry": ["sci","chem"],"BSc in Mathematics": ["sci","math"],"BSc in Applied Statistics": ["sci","stat"],"BSc in Biotechnology": ["sci","bio","biotech"],"MBBS (Medicine)": ["health","med"],"BSc in Nursing": ["health","nurs"],"BPharm (Pharmacy)": ["health","pharm"],"BSc in Medical Laboratory Sciences": ["health","mls"],"LLB (Law)": ["law"],"BA in English": ["lit"],"BA in Psychology": ["psy"],"BEd in Education": ["edu"],"BA in Mass Communication": ["media"]};
  var RAW = [];
  function C(lv, id, name, icon, cat, diff, fee, weeks, topics, desc, learn, f) {
    RAW.push(Object.assign({lv: lv, id: id, name: name, icon: icon, cat: cat, diff: diff, fee: fee, weeks: weeks, topics: topics, desc: desc, learn: learn}, f || {}));
  }

  /* ---------- CHILD (age 3 - 7) ---------- */
  C('CHILD', 'K101', 'Story Time Adventures', '📖', 'Stories', 'Beginner', 3000, 8, ['The Little Rabbit', 'The Clever Crow', 'Friends in the Forest', 'Our Own Story'], 'Fun picture stories read aloud with songs and actions. Children learn new words, listening skills and good habits.', ['Listen and answer story questions', 'Learn 50 new words', 'Retell a story in their own words'], {minA: 3, maxA: 7});
  C('CHILD', 'K102', 'Fun with Numbers', '🔢', 'Numbers', 'Beginner', 3500, 8, ['Counting 1 - 10', 'Counting 11 - 20', 'Adding with Toys', 'Shapes & Patterns'], 'Counting, shapes and simple adding through games, blocks and songs.', ['Count up to 20', 'Recognise basic shapes', 'Add small numbers with objects'], {minA: 4, maxA: 7});
  C('CHILD', 'K103', 'Colours & Creative Art', '🎨', 'Art', 'Beginner', 3000, 6, ['Primary Colours', 'Mixing Colours', 'Draw a Panda', 'Paper Crafts'], 'Colourful, playful art lessons. Children draw animals, mix colours and make simple crafts.', ['Name and mix colours', 'Draw simple shapes and animals', 'Make paper crafts'], {minA: 3, maxA: 7});
  C('CHILD', 'K104', 'Sing & Rhyme', '🎵', 'Music', 'Beginner', 2500, 6, ['Nursery Rhymes', 'Action Songs', 'Rhythm & Clapping', 'Mini Concert'], 'Songs, rhythm and movement that build language and confidence.', ['Sing 10 rhymes', 'Keep a simple beat', 'Perform on stage with friends'], {minA: 3, maxA: 7});
  C('CHILD', 'K105', 'Animals & Nature Explorers', '🐼', 'Nature', 'Beginner', 3000, 8, ['Farm Animals', 'Jungle Animals', 'Plants & Trees', 'Weather & Seasons'], 'Meet animals and explore plants and weather with videos, pictures and easy experiments.', ['Name 30 animals and their sounds', 'Grow a seed at home', 'Talk about the weather'], {minA: 3, maxA: 7});
  C('CHILD', 'K106', 'Letters & First Words', '🔤', 'Language', 'Beginner', 3500, 10, ['Letter Sounds A - M', 'Letter Sounds N - Z', 'Tracing Letters', 'First Words'], 'Learn letters, their sounds and write first words with tracing sheets and games.', ['Recognise all letters', 'Trace letters neatly', 'Read 20 first words'], {minA: 4, maxA: 7});
  C('CHILD', 'K107', 'Little Coders', '🎮', 'Technology', 'Beginner', 4000, 6, ['Giving Instructions', 'Move the Robot', 'Patterns & Loops', 'My First Game'], 'Screen-light coding games that teach step-by-step thinking.', ['Give clear step-by-step instructions', 'Spot patterns', 'Build a tiny game'], {minA: 6, maxA: 7});

  /* ---------- SCHOOL (Grade 1 - 11) ---------- */
  C('SCHOOL', 'S201', 'Mother Tongue - Reading & Writing', '🗣', 'Languages', 'Beginner', 3500, 12, ['Letters & Words', 'Sentences', 'Short Paragraphs', 'Story Writing'], 'Build strong reading and writing skills in the mother tongue with practice sheets and stories.', ['Read fluently', 'Write clear sentences', 'Compose a short story'], {minG: 1, maxG: 5});
  C('SCHOOL', 'S202', 'English for Young Learners', '🔤', 'Languages', 'Beginner', 3500, 12, ['Phonics', 'Everyday Words', 'Simple Sentences', 'Speaking Practice'], 'Phonics, vocabulary and simple conversation for primary students.', ['Read simple English books', 'Build 200 new words', 'Speak in short sentences'], {minG: 1, maxG: 5});
  C('SCHOOL', 'S203', 'Primary Mathematics', '🧮', 'Mathematics', 'Beginner', 4000, 16, ['Number Sense', 'Addition & Subtraction', 'Multiplication', 'Fractions & Measurement'], 'Clear, step-by-step maths for Grades 1 - 5 with games and weekly quizzes.', ['Calculate with confidence', 'Understand fractions', 'Solve word problems'], {minG: 1, maxG: 5});
  C('SCHOOL', 'S204', 'Environment Studies', '🌳', 'Science', 'Beginner', 3500, 12, ['Plants & Animals', 'Water & Air', 'Our Community', 'Caring for Nature'], 'Explore the world around us with pictures, short videos and simple activities.', ['Describe living things', 'Understand the water cycle', 'Care for the environment'], {minG: 1, maxG: 5});
  C('SCHOOL', 'S205', 'Grade 5 Scholarship Exam Preparation', '🏅', 'Exam Prep', 'Intermediate', 5500, 20, ['Intelligence Tests', 'Mathematics Papers', 'Language Papers', 'Model Papers'], 'Focused preparation for the Grade 5 Scholarship examination with past papers and model tests.', ['Solve intelligence-test questions', 'Manage exam time', 'Score higher in model papers'], {minG: 5, maxG: 5});
  C('SCHOOL', 'S206', 'Mathematics - Grades 6 to 9', '📐', 'Mathematics', 'Intermediate', 5000, 24, ['Algebra Basics', 'Geometry', 'Ratios & Percentages', 'Data Handling'], 'Build a strong foundation for O/L with clear explanations and lots of practice.', ['Solve algebra problems', 'Prove simple geometry results', 'Read and draw graphs'], {minG: 6, maxG: 9});
  C('SCHOOL', 'S207', 'Science - Grades 6 to 9', '🔬', 'Science', 'Intermediate', 5000, 24, ['Living Things', 'Matter & Energy', 'Forces & Motion', 'Earth & Space'], 'Biology, chemistry and physics made simple with experiments and quizzes.', ['Explain scientific ideas', 'Carry out safe experiments', 'Answer structured questions'], {minG: 6, maxG: 9});
  C('SCHOOL', 'S208', 'English Communication', '🗣', 'Languages', 'Intermediate', 4500, 16, ['Grammar in Use', 'Speaking & Listening', 'Letters & Emails', 'Essay Writing'], 'Improve spoken and written English for school and everyday life.', ['Hold confident conversations', 'Write clear essays', 'Use correct grammar'], {minG: 6, maxG: 11});
  C('SCHOOL', 'S209', 'History & Geography', '🌍', 'Humanities', 'Intermediate', 4000, 16, ['Ancient Sri Lanka', 'Maps & Directions', 'World Climates', 'Heritage Sites'], 'Stories of the past and the world around us with maps, timelines and quizzes.', ['Read maps', 'Build timelines', 'Describe world climates'], {minG: 6, maxG: 9});
  C('SCHOOL', 'S210', 'ICT for Students', '💻', 'Technology', 'Beginner', 4500, 12, ['Computer Basics', 'Typing & Documents', 'Internet Safety', 'Intro to Programming'], 'Practical computer skills, online safety and a first taste of programming.', ['Use a computer confidently', 'Make documents and slides', 'Stay safe online'], {minG: 6, maxG: 11});
  C('SCHOOL', 'S211', 'O/L Mathematics', '📐', 'Mathematics', 'Advanced', 6500, 30, ['Algebra & Equations', 'Geometry & Trigonometry', 'Statistics', 'Past Paper Practice'], 'Complete O/L Mathematics syllabus with weekly tests and past paper discussions.', ['Master every O/L topic', 'Solve past papers quickly', 'Avoid common mistakes'], {minG: 10, maxG: 11});
  C('SCHOOL', 'S212', 'O/L Science', '🔬', 'Science', 'Advanced', 6500, 30, ['Physics Essentials', 'Chemistry Essentials', 'Biology Essentials', 'Model Papers'], 'Covers the full O/L Science syllabus with practical explanations and model papers.', ['Understand key science concepts', 'Answer essay questions', 'Improve exam marks'], {minG: 10, maxG: 11});
  C('SCHOOL', 'S213', 'O/L English Language', '📝', 'Languages', 'Advanced', 5500, 24, ['Reading Comprehension', 'Writing Tasks', 'Grammar Revision', 'Model Papers'], 'Prepare for the O/L English paper with reading, writing and grammar practice.', ['Write letters and essays', 'Improve comprehension', 'Revise grammar'], {minG: 10, maxG: 11});

  /* ---------- A/L (stream based) ---------- */
  C('AL', 'A301', 'Combined Mathematics', '📐', 'Mathematics', 'Advanced', 6000, 24, ['Differentiation', 'Integration', 'Vectors & Mechanics', 'Past Papers'], 'Complete A/L Combined Mathematics with weekly tests, past paper discussions and model papers.', ['Pure and applied mathematics', 'Exam technique', 'Time management'], {streams: ['Physical']});
  C('AL', 'A302', 'Physics', '⚛', 'Science', 'Advanced', 6000, 24, ['Mechanics', 'Waves & Optics', 'Electricity', 'Practical Skills'], 'Physics theory, structured and essay questions with practical demonstrations.', ['Understand core physics', 'Solve numerical problems', 'Handle practical questions'], {streams: ['Physical', 'Biological']});
  C('AL', 'A303', 'Chemistry', '⚗', 'Science', 'Advanced', 6000, 24, ['Atomic Structure', 'Organic Chemistry', 'Chemical Equilibrium', 'Past Papers'], 'Inorganic, organic and physical chemistry with problem solving workshops.', ['Balance and predict reactions', 'Draw organic mechanisms', 'Calculate with moles'], {streams: ['Physical', 'Biological']});
  C('AL', 'A304', 'Biology', '🧬', 'Science', 'Advanced', 6000, 24, ['Cell Biology', 'Genetics', 'Human Physiology', 'Ecology'], 'Detailed Biology coverage with diagrams, short notes and model papers.', ['Draw and label diagrams', 'Explain genetic crosses', 'Write structured essays'], {streams: ['Biological']});
  C('AL', 'A305', 'Accounting', '💰', 'Commerce', 'Advanced', 5500, 24, ['Double Entry', 'Final Accounts', 'Costing', 'Past Papers'], 'Practical accounting with worked examples for the A/L Commerce stream.', ['Prepare final accounts', 'Calculate costs', 'Solve past papers'], {streams: ['Commerce']});
  C('AL', 'A306', 'Business Studies', '📊', 'Commerce', 'Advanced', 5500, 24, ['Business Environment', 'Marketing', 'Human Resources', 'Case Studies'], 'Understand how businesses work using local case studies.', ['Explain business functions', 'Analyse case studies', 'Write structured answers'], {streams: ['Commerce']});
  C('AL', 'A307', 'Economics', '📈', 'Commerce', 'Advanced', 5500, 24, ['Demand & Supply', 'National Income', 'Money & Banking', 'Sri Lankan Economy'], 'Micro and macro economics with real examples and graph practice.', ['Draw and explain graphs', 'Understand the Sri Lankan economy', 'Answer essay questions'], {streams: ['Commerce', 'Arts']});
  C('AL', 'A308', 'Political Science', '🗳', 'Arts', 'Advanced', 5000, 24, ['Political Theory', 'Constitution', 'International Relations', 'Essay Practice'], 'Key ideas, institutions and essay writing for the Arts stream.', ['Compare political systems', 'Write balanced essays', 'Use examples'], {streams: ['Arts']});
  C('AL', 'A309', 'Logic & Scientific Method', '🧠', 'Arts', 'Advanced', 5000, 24, ['Arguments', 'Deduction', 'Induction', 'Past Papers'], 'Clear thinking skills with plenty of exam practice.', ['Test arguments', 'Use symbols correctly', 'Solve past papers'], {streams: ['Arts']});
  C('AL', 'A310', 'Engineering Technology', '⚙', 'Technology', 'Advanced', 6000, 24, ['Mechanics of Materials', 'Electrical Basics', 'Drawings', 'Practical Projects'], 'Principles of engineering with workshop demonstrations and projects.', ['Read engineering drawings', 'Calculate loads', 'Build a small project'], {streams: ['Technology']});
  C('AL', 'A311', 'Science for Technology', '🔬', 'Technology', 'Advanced', 6000, 24, ['Physics Basics', 'Chemistry Basics', 'Biology Basics', 'Model Papers'], 'Science foundations needed for the Technology stream.', ['Apply science to technology', 'Solve calculations', 'Practice past papers'], {streams: ['Technology']});
  C('AL', 'A312', 'ICT for A/L', '💻', 'Technology', 'Intermediate', 5000, 24, ['Programming', 'Databases', 'Networks', 'Web Design'], 'Programming, databases and networking for the A/L ICT examination.', ['Write simple programs', 'Design a database', 'Understand networks'], {streams: ['ALL']});
  C('AL', 'A313', 'General English', '🔤', 'Languages', 'Intermediate', 3500, 24, ['Reading', 'Writing', 'Grammar', 'Model Papers'], 'Prepare for the General English paper required for every stream.', ['Improve comprehension', 'Write essays and letters', 'Revise grammar'], {streams: ['ALL']});
  C('AL', 'A314', 'Common General Test', '🎯', 'Exam Prep', 'Intermediate', 3000, 20, ['Current Affairs', 'Quantitative Reasoning', 'Logical Reasoning', 'Model Papers'], 'Preparation for the Common General Test (GIT) taken by every A/L student.', ['Score higher in the GIT', 'Think quickly', 'Manage time'], {streams: ['ALL']});

  /* ---------- UNDERGRADUATE (32 degrees; every course has tags `g` = the degree groups it suits) ---------- */
  C('UNDERGRAD', "U401", "Programming Fundamentals (Python)", "\ud83d\udc0d", "Computing", "Beginner", 8500, 10, ["Core Syntax", "Data Structures", "Functions & Files", "Mini Projects"], "A friendly start to programming with Python. Solve problems and build real mini projects.", ["Write clean Python code", "Use lists and dictionaries", "Build 3 mini projects"], {g: ["cs", "mecha", "stat", "math", "phys"]});
  C('UNDERGRAD', "U402", "Web Development Fundamentals", "\ud83c\udf10", "Computing", "Beginner", 7500, 8, ["HTML Essentials", "CSS Layouts", "JavaScript Basics", "Portfolio Project"], "Create real websites with HTML, CSS and JavaScript and publish a portfolio.", ["Build responsive pages", "Add interactivity", "Publish your site"], {g: ["cs", "is", "media"]});
  C('UNDERGRAD', "U403", "Data Structures & Algorithms", "\ud83e\udde0", "Computing", "Advanced", 12000, 12, ["Complexity", "Linear Structures", "Trees & Hashing", "Graphs & Sorting"], "Master arrays, trees, graphs and sorting with exam-style practice.", ["Analyse complexity", "Implement core structures", "Prepare for interviews"], {g: ["cs"]});
  C('UNDERGRAD', "U404", "Database Systems", "\ud83d\uddc3", "Computing", "Intermediate", 9500, 10, ["Data Modelling", "Relational Model", "SQL", "Transactions"], "Design reliable databases and query them with confidence.", ["Draw ER diagrams", "Normalize tables", "Write joins and sub-queries"], {g: ["cs", "is", "ds"]});
  C('UNDERGRAD', "U405", "Software Engineering", "\ud83d\udee0", "Computing", "Intermediate", 10000, 12, ["Requirements", "Design & UML", "Testing", "Team Project"], "Plan, design, test and deliver software as a team.", ["Write requirements", "Model with UML", "Test and release"], {g: ["cs", "is"]});
  C('UNDERGRAD', "U414", "Object-Oriented Programming (Java)", "\u2615", "Computing", "Intermediate", 9000, 12, ["Classes & Objects", "Inheritance", "Polymorphism", "Design Patterns"], "Think in objects: build maintainable Java programs with inheritance and design patterns.", ["Model problems with classes", "Apply SOLID ideas", "Use common design patterns"], {g: ["cs"]});
  C('UNDERGRAD', "U415", "Operating Systems", "\ud83d\udda5", "Computing", "Advanced", 10000, 12, ["Processes & Threads", "Memory Management", "File Systems", "Scheduling"], "How an operating system really works, with hands-on Linux labs.", ["Explain process scheduling", "Understand virtual memory", "Use the Linux shell"], {g: ["cs"]});
  C('UNDERGRAD', "U416", "Computer Networks", "\ud83d\udce1", "Computing", "Intermediate", 9500, 10, ["OSI & TCP/IP", "IP Addressing", "Routing & Switching", "Network Labs"], "Understand how data travels across the internet and configure small networks.", ["Subnet IP addresses", "Configure routers in a simulator", "Troubleshoot networks"], {g: ["cs", "sec", "is"]});
  C('UNDERGRAD', "U417", "Discrete Mathematics", "\u2211", "Computing", "Intermediate", 7500, 10, ["Logic & Proofs", "Sets & Relations", "Graph Theory", "Counting"], "The mathematics behind computing, taught with plenty of worked examples.", ["Write simple proofs", "Work with sets and relations", "Solve counting problems"], {g: ["cs", "math"]});
  C('UNDERGRAD', "U418", "Software Testing & Quality", "\u2705", "Computing", "Intermediate", 8500, 8, ["Test Design", "Unit Testing", "Automation", "Bug Reports"], "Find bugs early: design test cases, automate them and report issues clearly.", ["Design test cases", "Write automated tests", "Report defects professionally"], {g: ["se"]});
  C('UNDERGRAD', "U419", "Agile & Project Management", "\ud83d\udccb", "Computing", "Intermediate", 8000, 8, ["Scrum Basics", "User Stories", "Estimating & Planning", "Sprint Project"], "Run projects the agile way with sprints, boards and retrospectives.", ["Write user stories", "Plan a sprint", "Lead a stand-up"], {g: ["se", "is", "biz"]});
  C('UNDERGRAD', "U420", "Machine Learning Basics", "\ud83e\udd16", "Computing", "Advanced", 12500, 12, ["Regression", "Classification", "Clustering", "Model Evaluation"], "Train your first machine-learning models with Python and learn to judge them fairly.", ["Prepare data for models", "Train and evaluate models", "Avoid over-fitting"], {g: ["ds"]});
  C('UNDERGRAD', "U421", "Data Visualization", "\ud83d\udcc8", "Computing", "Intermediate", 8500, 8, ["Chart Choice", "Dashboards", "Storytelling with Data", "Visual Project"], "Turn numbers into clear stories with charts and dashboards.", ["Pick the right chart", "Build an interactive dashboard", "Present insights"], {g: ["ds", "stat", "biz"]});
  C('UNDERGRAD', "U422", "Cyber Security Fundamentals", "\ud83d\udd12", "Computing", "Beginner", 9500, 10, ["Threats & Attacks", "Cryptography Basics", "Secure Passwords & Access", "Incident Response"], "Learn how systems get attacked and how to defend them.", ["Recognise common attacks", "Use encryption correctly", "Respond to incidents"], {g: ["sec", "is"]});
  C('UNDERGRAD', "U423", "Ethical Hacking Lab", "\ud83d\udd75", "Computing", "Advanced", 12000, 10, ["Reconnaissance", "Vulnerability Scanning", "Web App Attacks", "Reporting"], "Practise legally in a safe lab: find vulnerabilities, then write a proper report.", ["Scan for vulnerabilities", "Test web applications", "Write a security report"], {g: ["sec"]});
  C('UNDERGRAD', "U406", "Principles of Management", "\ud83d\udcbc", "Business", "Beginner", 7000, 10, ["Planning", "Organising", "Leading", "Controlling"], "Core ideas of management with local and global case studies.", ["Understand management functions", "Analyse cases", "Lead a team project"], {g: ["biz", "is", "arch", "qs"]});
  C('UNDERGRAD', "U407", "Financial Accounting", "\ud83d\udcb0", "Business", "Intermediate", 8000, 12, ["Double Entry", "Financial Statements", "Ratio Analysis", "Case Practice"], "Prepare and interpret financial statements with worked examples.", ["Record transactions", "Prepare statements", "Interpret ratios"], {g: ["biz", "qs"]});
  C('UNDERGRAD', "U408", "Marketing Fundamentals", "\ud83d\udce3", "Business", "Beginner", 7000, 8, ["Consumer Behaviour", "Segmentation", "The 4 Ps", "Campaign Project"], "Learn how products reach customers, then plan your own campaign.", ["Research customers", "Plan the marketing mix", "Present a campaign"], {g: ["biz", "media"]});
  C('UNDERGRAD', "U424", "Business Economics", "\ud83d\udcc9", "Business", "Beginner", 7000, 10, ["Demand & Supply", "Market Structures", "National Income", "Inflation & Policy"], "Economic thinking for managers, using Sri Lankan examples.", ["Explain market behaviour", "Read economic news", "Apply cost-benefit thinking"], {g: ["biz", "bank"]});
  C('UNDERGRAD', "U425", "Human Resource Management", "\ud83d\udc65", "Business", "Intermediate", 7500, 10, ["Recruitment", "Training", "Performance Appraisal", "Employment Law Basics"], "How organisations find, grow and keep good people.", ["Plan recruitment", "Design a training plan", "Conduct appraisals"], {g: ["hr", "edu"]});
  C('UNDERGRAD', "U426", "Corporate Finance", "\ud83c\udfe6", "Business", "Advanced", 10500, 12, ["Time Value of Money", "Capital Budgeting", "Risk & Return", "Working Capital"], "Make investment and financing decisions like a finance manager.", ["Value projects (NPV, IRR)", "Understand risk and return", "Manage working capital"], {g: ["acc", "bank"]});
  C('UNDERGRAD', "U427", "Banking Operations", "\ud83c\udfe7", "Business", "Intermediate", 8500, 8, ["Retail Banking", "Lending & Credit", "Payments & Cards", "Banking Regulation"], "How banks work day to day, from deposits to digital payments.", ["Explain bank products", "Assess credit applications", "Understand regulation"], {g: ["bank"]});
  C('UNDERGRAD', "U428", "Digital Marketing", "\ud83d\udcf1", "Business", "Intermediate", 8000, 8, ["Social Media Strategy", "Search Basics", "Content Creation", "Analytics"], "Plan and measure online campaigns across social media and search.", ["Create a content calendar", "Run a small ad campaign", "Read analytics reports"], {g: ["mkt", "media"]});
  C('UNDERGRAD', "U429", "Business Statistics", "\ud83d\udcca", "Business", "Intermediate", 7500, 10, ["Descriptive Statistics", "Sampling", "Hypothesis Tests", "Forecasting"], "Statistics for business decisions using spreadsheets.", ["Summarise business data", "Test simple claims", "Forecast sales"], {g: ["biz", "hr", "mkt", "bank", "acc"]});
  C('UNDERGRAD', "U409", "Engineering Mathematics", "\ud83d\udcd0", "Engineering", "Advanced", 9000, 14, ["Calculus", "Linear Algebra", "Differential Equations", "Applications"], "Mathematical tools every engineering student needs.", ["Solve differential equations", "Use matrices", "Apply maths to engineering"], {g: ["eng", "math", "phys"]});
  C('UNDERGRAD', "U410", "Circuit Analysis", "\u26a1", "Engineering", "Intermediate", 9500, 12, ["Ohm & Kirchhoff", "Network Theorems", "AC Circuits", "Lab Practice"], "Analyse electrical circuits with theory, simulations and lab work.", ["Analyse DC and AC circuits", "Use network theorems", "Use simulation tools"], {g: ["elec", "mecha"]});
  C('UNDERGRAD', "U430", "Engineering Drawing & CAD", "\ud83d\udccf", "Engineering", "Beginner", 8500, 10, ["Orthographic Projection", "Sections & Dimensions", "2D CAD", "3D Modelling"], "Read and produce engineering drawings, then model parts in CAD.", ["Draw orthographic views", "Dimension drawings correctly", "Model parts in 3D CAD"], {g: ["civil", "mech", "mecha", "arch", "qs"]});
  C('UNDERGRAD', "U431", "Statics & Mechanics of Materials", "\ud83e\uddf1", "Engineering", "Intermediate", 9500, 12, ["Forces & Equilibrium", "Stress & Strain", "Beams", "Failure Theories"], "How structures carry loads, from simple trusses to beams.", ["Solve equilibrium problems", "Calculate stress and strain", "Analyse beams"], {g: ["civil", "mech", "mecha"]});
  C('UNDERGRAD', "U432", "Thermodynamics & Fluid Mechanics", "\ud83c\udf21", "Engineering", "Advanced", 10500, 12, ["Laws of Thermodynamics", "Heat Engines", "Fluid Statics", "Pipe Flow"], "Energy and fluids: the foundation of mechanical and civil design.", ["Apply the laws of thermodynamics", "Analyse heat engines", "Calculate pipe flow"], {g: ["mech", "civil"]});
  C('UNDERGRAD', "U433", "Structural Analysis", "\ud83c\udf09", "Engineering", "Advanced", 11000, 12, ["Determinate Structures", "Indeterminate Structures", "Influence Lines", "Design Project"], "Analyse beams, frames and bridges and design a small structure.", ["Analyse frames", "Draw bending moment diagrams", "Complete a design project"], {g: ["civil"]});
  C('UNDERGRAD', "U434", "Surveying & Geomatics", "\ud83e\udded", "Engineering", "Intermediate", 8500, 10, ["Levelling", "Traversing", "Total Station", "GIS Basics"], "Measure land accurately with modern instruments and map it digitally.", ["Run a levelling survey", "Use a total station", "Create simple GIS maps"], {g: ["civil", "qs", "arch"]});
  C('UNDERGRAD', "U435", "Digital Electronics", "\ud83d\udcdf", "Engineering", "Intermediate", 9000, 10, ["Logic Gates", "Combinational Circuits", "Flip-flops", "Microcontroller Project"], "From logic gates to a working microcontroller project.", ["Design logic circuits", "Use flip-flops and counters", "Program a microcontroller"], {g: ["elec", "mecha"]});
  C('UNDERGRAD', "U436", "Control Systems", "\ud83c\udf9b", "Engineering", "Advanced", 11000, 12, ["Modelling Systems", "Transfer Functions", "Stability", "PID Control"], "Make machines behave: model systems and design controllers.", ["Model dynamic systems", "Check stability", "Tune a PID controller"], {g: ["elec", "mecha"]});
  C('UNDERGRAD', "U437", "Construction Technology", "\ud83c\udfd7", "Built Environment", "Intermediate", 8500, 10, ["Materials", "Foundations", "Building Services", "Site Management"], "How buildings are built, from foundations to finishes.", ["Choose construction materials", "Understand foundations", "Plan site activities"], {g: ["civil", "qs", "arch"]});
  C('UNDERGRAD', "U438", "Quantity Surveying & Cost Estimation", "\ud83e\uddee", "Built Environment", "Intermediate", 10000, 12, ["Measurement Rules", "Bills of Quantities", "Cost Planning", "Contracts"], "Measure, price and control the cost of construction projects.", ["Prepare a bill of quantities", "Estimate project costs", "Understand building contracts"], {g: ["qs"]});
  C('UNDERGRAD', "U439", "Architectural Design Studio", "\ud83c\udfdb", "Built Environment", "Intermediate", 11000, 14, ["Site Analysis", "Concept Design", "Drawings & Models", "Design Critique"], "Develop a design from site analysis to a presented model.", ["Analyse a site", "Develop a design concept", "Present drawings and models"], {g: ["arch"]});
  C('UNDERGRAD', "U411", "Statistics for Data Analysis", "\ud83d\udcca", "Science", "Intermediate", 8500, 10, ["Descriptive Statistics", "Probability", "Hypothesis Testing", "Regression"], "Practical statistics with spreadsheets and Python.", ["Summarise data", "Test hypotheses", "Fit regression models"], {g: ["stat", "ds", "psy", "bio", "med", "math", "edu", "mls"]});
  C('UNDERGRAD', "U440", "Calculus & Linear Algebra", "\u222b", "Science", "Advanced", 8500, 12, ["Limits & Derivatives", "Integration", "Matrices", "Eigenvalues"], "The mathematics that every science student relies on.", ["Differentiate and integrate", "Work with matrices", "Use eigenvalues"], {g: ["sci", "cs"]});
  C('UNDERGRAD', "U441", "Physics for Scientists", "\u269b", "Science", "Intermediate", 9000, 12, ["Mechanics", "Waves", "Electromagnetism", "Modern Physics"], "University-level physics with demonstrations and problem classes.", ["Solve mechanics problems", "Understand waves and fields", "Meet modern physics"], {g: ["phys", "eng"]});
  C('UNDERGRAD', "U442", "Organic Chemistry", "\u2697", "Science", "Advanced", 9500, 12, ["Functional Groups", "Reaction Mechanisms", "Stereochemistry", "Spectroscopy"], "Predict and explain organic reactions step by step.", ["Name organic compounds", "Draw reaction mechanisms", "Read simple spectra"], {g: ["chem", "pharm", "biotech", "bio"]});
  C('UNDERGRAD', "U443", "Cell Biology", "\ud83e\uddeb", "Science", "Intermediate", 8500, 10, ["Cell Structure", "Membranes & Transport", "Cell Division", "Cell Signalling"], "How cells work: the base for biology, health and biotechnology.", ["Describe cell organelles", "Explain transport and signalling", "Follow the cell cycle"], {g: ["bio", "biotech", "med", "nurs", "mls", "pharm"]});
  C('UNDERGRAD', "U444", "Genetics & Molecular Biology", "\ud83e\uddec", "Science", "Advanced", 9500, 12, ["Mendelian Genetics", "DNA & Replication", "Gene Expression", "Lab Techniques"], "From inheritance to DNA technology with practical lab sessions.", ["Solve genetics problems", "Explain gene expression", "Describe PCR and cloning"], {g: ["bio", "biotech", "med", "mls"]});
  C('UNDERGRAD', "U445", "Laboratory Skills & Safety", "\ud83e\udd7c", "Science", "Beginner", 6500, 6, ["Lab Safety", "Measurement & Error", "Recording Results", "Lab Report Writing"], "Work safely and accurately in any science laboratory.", ["Follow lab safety rules", "Estimate measurement error", "Write a lab report"], {g: ["sci", "health"]});
  C('UNDERGRAD', "U446", "Human Anatomy", "\ud83e\udec0", "Health", "Intermediate", 11000, 14, ["Musculoskeletal System", "Cardiovascular System", "Respiratory System", "Nervous System"], "Learn the structure of the human body with diagrams and models.", ["Identify body structures", "Relate structure to function", "Use anatomical terms"], {g: ["health"]});
  C('UNDERGRAD', "U447", "Human Physiology", "\ud83e\udec1", "Health", "Intermediate", 11000, 14, ["Homeostasis", "Circulation & Breathing", "Digestion & Metabolism", "Nerves & Hormones"], "How the body keeps itself working, system by system.", ["Explain homeostasis", "Describe major organ systems", "Link physiology to disease"], {g: ["med", "nurs", "mls", "pharm"]});
  C('UNDERGRAD', "U448", "Biochemistry", "\ud83e\uddea", "Health", "Advanced", 10500, 12, ["Proteins & Enzymes", "Carbohydrates & Lipids", "Metabolism", "Clinical Biochemistry"], "The chemistry of life and its use in diagnosis and medicine.", ["Explain enzyme action", "Follow metabolic pathways", "Interpret lab results"], {g: ["med", "pharm", "mls", "biotech"]});
  C('UNDERGRAD', "U449", "Pharmacology Essentials", "\ud83d\udc8a", "Health", "Advanced", 11000, 12, ["Drug Action", "Absorption & Metabolism", "Common Drug Groups", "Adverse Effects"], "How medicines work, how the body handles them and how to use them safely.", ["Explain drug action", "Describe drug metabolism", "Recognise side effects"], {g: ["pharm", "med", "nurs"]});
  C('UNDERGRAD', "U450", "Nursing Fundamentals", "\ud83e\ude7a", "Health", "Beginner", 9500, 12, ["Patient Care Basics", "Vital Signs", "Infection Control", "Documentation"], "The essential skills every nurse needs, practised in a skills lab.", ["Measure vital signs", "Follow infection control", "Document care correctly"], {g: ["nurs"]});
  C('UNDERGRAD', "U451", "Clinical Communication Skills", "\ud83d\udcac", "Health", "Beginner", 7500, 8, ["Active Listening", "Taking a History", "Breaking Bad News", "Role Plays"], "Communicate with patients and families with kindness and clarity.", ["Take a patient history", "Explain clearly", "Show empathy"], {g: ["med", "nurs", "pharm", "psy"]});
  C('UNDERGRAD', "U452", "Medical Ethics & Professionalism", "\u2696", "Health", "Beginner", 6500, 6, ["Core Principles", "Consent", "Confidentiality", "Case Discussions"], "Ethical thinking for future healthcare professionals.", ["Apply the four principles", "Understand consent", "Handle confidential information"], {g: ["med", "nurs", "pharm", "mls", "law"]});
  C('UNDERGRAD', "U453", "Medical Microbiology", "\ud83e\udda0", "Health", "Intermediate", 9500, 10, ["Bacteria", "Viruses", "Sterilisation", "Lab Identification"], "Microbes that cause disease, and how labs identify and control them.", ["Classify microorganisms", "Explain infection control", "Run basic identification tests"], {g: ["mls", "med", "biotech", "nurs"]});
  C('UNDERGRAD', "U454", "Legal System of Sri Lanka", "\u2696", "Law", "Beginner", 7500, 10, ["Sources of Law", "Courts & Procedure", "Legal Profession", "Case Reading"], "How the Sri Lankan legal system is organised and how to read cases.", ["Explain sources of law", "Describe court structure", "Read a law report"], {g: ["law"]});
  C('UNDERGRAD', "U455", "Constitutional Law", "\ud83d\udcdc", "Law", "Intermediate", 8500, 12, ["Constitutional Principles", "Fundamental Rights", "Separation of Powers", "Landmark Cases"], "Rights, powers and institutions under the Constitution.", ["Explain fundamental rights", "Analyse landmark cases", "Write constitutional essays"], {g: ["law", "lit"]});
  C('UNDERGRAD', "U456", "Law of Contract", "\ud83d\udcdd", "Law", "Intermediate", 8500, 12, ["Formation", "Terms", "Breach & Remedies", "Problem Questions"], "Agreements and their enforcement, with problem-solving practice.", ["Identify a valid contract", "Analyse breach", "Answer problem questions"], {g: ["law", "biz"]});
  C('UNDERGRAD', "U457", "Criminal Law", "\ud83d\udea8", "Law", "Intermediate", 8500, 12, ["Elements of Crime", "Defences", "Offences against the Person", "Case Studies"], "The principles of criminal liability illustrated with cases.", ["Explain mens rea and actus reus", "Apply defences", "Analyse case studies"], {g: ["law", "psy"]});
  C('UNDERGRAD', "U458", "Legal Research & Writing", "\ud83d\udd8b", "Law", "Beginner", 6500, 8, ["Finding Sources", "Citation (OSCOLA)", "Case Notes", "Moot Memo"], "Research the law efficiently and write like a lawyer.", ["Find cases and statutes", "Cite correctly", "Write a legal memo"], {g: ["law"]});
  C('UNDERGRAD', "U459", "English Literature: Poetry & Prose", "\ud83d\udcda", "Arts & Education", "Intermediate", 7500, 12, ["Reading Poetry", "The Novel", "Short Stories", "Critical Essay"], "Read, discuss and write about great poems, stories and novels.", ["Analyse poems closely", "Discuss themes and style", "Write a critical essay"], {g: ["lit", "media"]});
  C('UNDERGRAD', "U460", "Introduction to Linguistics", "\ud83d\udde3", "Arts & Education", "Beginner", 7000, 10, ["Phonetics", "Syntax", "Semantics", "Language & Society"], "How language works: sounds, sentences, meaning and use.", ["Transcribe sounds", "Draw syntax trees", "Discuss language variation"], {g: ["lit", "edu", "psy"]});
  C('UNDERGRAD', "U461", "Creative Writing Workshop", "\u270f", "Arts & Education", "Beginner", 6500, 8, ["Finding Ideas", "Characters & Voice", "Dialogue & Setting", "Portfolio"], "Write stories and scenes with feedback in a friendly workshop.", ["Develop characters", "Write natural dialogue", "Edit your own work"], {g: ["lit", "media"]});
  C('UNDERGRAD', "U462", "Introduction to Psychology", "\ud83e\udde0", "Arts & Education", "Beginner", 7500, 10, ["Brain & Behaviour", "Learning & Memory", "Personality", "Mental Health Basics"], "The science of mind and behaviour for beginners.", ["Describe major theories", "Explain memory and learning", "Understand common disorders"], {g: ["psy", "edu", "nurs", "med", "media"]});
  C('UNDERGRAD', "U463", "Developmental & Cognitive Psychology", "\ud83d\udc76", "Arts & Education", "Intermediate", 8500, 12, ["Child Development", "Attention & Memory", "Adolescence", "Adult Development"], "How thinking and behaviour develop across the lifespan.", ["Compare development theories", "Explain cognitive processes", "Apply ideas to real cases"], {g: ["psy", "edu"]});
  C('UNDERGRAD', "U464", "Research Methods in Behavioural Science", "\ud83d\udd2c", "Arts & Education", "Intermediate", 8000, 10, ["Designing Studies", "Surveys & Interviews", "Analysing Data", "Ethics"], "Plan and run a small research study from question to report.", ["Design a study", "Collect and analyse data", "Follow research ethics"], {g: ["psy", "edu", "media"]});
  C('UNDERGRAD', "U465", "Educational Psychology", "\ud83c\udf93", "Arts & Education", "Intermediate", 7500, 10, ["How Students Learn", "Motivation", "Individual Differences", "Assessment"], "Use psychology to help every learner succeed.", ["Explain learning theories", "Motivate students", "Design fair assessments"], {g: ["edu"]});
  C('UNDERGRAD', "U466", "Curriculum & Teaching Methods", "\ud83d\udcd6", "Arts & Education", "Intermediate", 8000, 12, ["Lesson Planning", "Teaching Strategies", "Using Technology", "Micro-teaching"], "Plan and teach engaging lessons and reflect on your practice.", ["Write a lesson plan", "Use varied teaching methods", "Teach a short lesson"], {g: ["edu"]});
  C('UNDERGRAD', "U467", "Classroom Management", "\ud83e\uddd1", "Arts & Education", "Beginner", 6500, 8, ["Setting Routines", "Positive Behaviour", "Inclusive Classrooms", "Parent Communication"], "Keep a calm, positive and inclusive classroom.", ["Set clear routines", "Respond to misbehaviour calmly", "Work with parents"], {g: ["edu"]});
  C('UNDERGRAD', "U468", "Media Writing & Journalism", "\ud83d\udcf0", "Arts & Education", "Intermediate", 7500, 10, ["News Values", "Writing a News Story", "Interviewing", "Media Ethics"], "Report accurately and write clearly for print and online.", ["Write a news story", "Conduct interviews", "Apply media ethics"], {g: ["media"]});
  C('UNDERGRAD', "U469", "Digital Media Production", "\ud83c\udfac", "Arts & Education", "Intermediate", 9000, 10, ["Photography", "Video Editing", "Audio & Podcasts", "Final Production"], "Shoot, edit and publish photo, video and audio stories.", ["Frame good shots", "Edit video", "Produce a podcast"], {g: ["media", "mkt"]});
  C('UNDERGRAD', "U412", "Academic Writing & Research Methods", "\u270d", "Skills", "Beginner", 5000, 8, ["Reading Papers", "Structuring Essays", "Referencing", "Research Proposal"], "Write clearly, reference correctly and plan a research project.", ["Write structured essays", "Cite sources properly", "Draft a research proposal"], {g: ["GEN"]});
  C('UNDERGRAD', "U413", "Communication & Presentation Skills", "\ud83c\udfa4", "Skills", "Beginner", 5000, 6, ["Speaking Confidently", "Slide Design", "Interviews", "Group Presentations"], "Present with confidence and communicate clearly at university and work.", ["Deliver presentations", "Design clear slides", "Prepare for interviews"], {g: ["GEN"]});
  C('UNDERGRAD', "U470", "Career Skills & CV Writing", "\ud83d\udcbc", "Skills", "Beginner", 4500, 6, ["Career Goals", "CV & LinkedIn", "Interview Practice", "Internship Search"], "Get ready for internships and your first job.", ["Write a strong CV", "Practise interviews", "Find internships"], {g: ["GEN"]});
  C('UNDERGRAD', "U471", "Study Skills & Time Management", "\u23f0", "Skills", "Beginner", 4000, 4, ["Planning Your Week", "Note-taking", "Revision Techniques", "Exam Stress"], "Study smarter, manage your time and stay calm in exams.", ["Build a study timetable", "Take effective notes", "Revise efficiently"], {g: ["GEN"]});

  /* ---------- FREE courses: one free starter course for EVERY category of EVERY learner level ----------
     Fee 0 -> no payment is needed and they do not use up the 2 "free enrollment" slots of the paid courses. */
  (function () {
    var ICON = {Stories: '📖', Numbers: '🔢', Art: '🎨', Music: '🎵', Nature: '🐼', Language: '🔤', Technology: '💻', Languages: '🗣', Mathematics: '📐', Science: '🔬',
                'Exam Prep': '🏅', Humanities: '🌍', Commerce: '💰', Arts: '🎭', Computing: '💻', Business: '💼', Engineering: '⚙', 'Built Environment': '🏗',
                Health: '🩺', Law: '⚖', 'Arts & Education': '🎓', Skills: '🧠'};
    var PFX = {CHILD: 'K', SCHOOL: 'S', AL: 'A', UNDERGRAD: 'U'}, n = {CHILD: 0, SCHOOL: 0, AL: 0, UNDERGRAD: 0}, seen = {};
    RAW.slice().forEach(function (c) {
      var key = c.lv + '|' + c.cat; if (seen[key]) return; seen[key] = 1;
      n[c.lv]++;
      /* a free starter suits the SAME learners as the paid courses of its category (it must not leak into other degrees / streams / grades) */
      var sib = RAW.filter(function (x) { return x.lv === c.lv && x.cat === c.cat && !x.free; }), fld;
      if (c.lv === 'CHILD') {
        fld = {minA: Math.min.apply(null, sib.map(function (x) { return x.minA; })), maxA: 7};
      } else if (c.lv === 'SCHOOL') {
        fld = {minG: Math.min.apply(null, sib.map(function (x) { return x.minG; })), maxG: Math.max.apply(null, sib.map(function (x) { return x.maxG; }))};
      } else if (c.lv === 'AL') {
        var st = {}; sib.forEach(function (x) { x.streams.forEach(function (s) { if (s !== 'ALL') st[s] = 1; }); });
        fld = {streams: Object.keys(st).length ? Object.keys(st) : ['ALL']};
      } else {
        var cnt = {}; sib.forEach(function (x) { (x.g || []).forEach(function (t) { cnt[t] = (cnt[t] || 0) + 1; }); });
        var tags = Object.keys(cnt).filter(function (t) { return cnt[t] >= 2 || t === 'GEN'; });
        if (!tags.length) tags = Object.keys(cnt);
        fld = {g: tags.length ? tags : ['GEN']};
      }
      fld.free = true;
      var kid = c.lv === 'CHILD';
      C(c.lv, PFX[c.lv] + (900 + n[c.lv]), 'Free Starter: ' + c.cat, ICON[c.cat] || '🎁', c.cat, 'Beginner', 0, kid ? 2 : 3,
        ['Welcome & Overview', 'Key Ideas in ' + c.cat, kid ? 'Fun Activity' : 'Practice Activity', 'Quiz & Next Steps'],
        'A free starter course in ' + c.cat + '. Try the subject, meet the teacher and see what comes next. No payment needed.',
        kid ? ['Enjoy a fun first lesson', 'Try an easy activity', 'Choose what to learn next'] : ['Understand the basics of ' + c.cat, 'Try a hands-on activity', 'Know which course to take next'], fld);
    });
  })();

  RAW.forEach(function (c, i) {
    var p = POOL[c.lv];
    c.teacher = p.t[i % p.t.length]; c.role = p.role; c.lang = p.lang; c.schedule = p.sch[i % p.sch.length];
    c.reqs = c.reqs || (p.reqs.slice(0, 1 + (i % 2)));
    c.seats = [20, 30, 35, 40, 45, 60][i % 6]; c.taken = (i % 9 === 3) ? c.seats : Math.round(c.seats * (0.35 + (i * 7 % 5) / 10));
    c.rating = Math.round((4.2 + ((i * 37) % 9) / 10) * 10) / 10; if (c.rating > 5) c.rating = 5;
    c.reviews = 30 + (i * 53) % 190; c.color = G[i % G.length];
    c.syllabus = c.topics.map(function (t, k) { return ['Part ' + (k + 1) + ': ' + t, 'Lessons, practice activities and a short quiz.']; });
  });

  RAW.forEach(function (c, i) {
    if (!c.free) return;
    c.seats = 200; c.taken = 40 + (i * 13) % 90; c.schedule = 'Self-paced - start anytime'; c.reqs = ['No payment needed'];
    c.color = 'linear-gradient(135deg,#16a34a,#86efac)'; c.reviews = 60 + (i * 29) % 150;
  });

  /* ---------- who is looking? ---------- */
  var LEVEL_NAME = {CHILD: 'Child', SCHOOL: 'Grade 1 - 11', AL: 'A/L', UNDERGRAD: 'Undergraduate'};
  var LEVEL_ICON = {CHILD: '🧒', SCHOOL: '🎒', AL: '📚', UNDERGRAD: '🎓'};
  function me() {
    var el = document.getElementById('meData'), d = el ? el.dataset : {};
    return {id: d.id || 'guest', admin: d.admin === 'true', level: d.level || '', detail: (d.detail || '').trim()};
  }
  function streamOf(d) { var m = /^(Physical|Biological|Commerce|Arts|Technology)/i.exec(d); return m ? m[1][0].toUpperCase() + m[1].slice(1).toLowerCase() : ''; }
  function groupsOf(d) {
    if (DEGREES[d]) return DEGREES[d];
    var t = [], x = d.toLowerCase().replace(/software engineer\w*/g, 'software');   // old free-text degrees
    if (/comput|software|information|\bit\b|data|cyber|network|multimedia/.test(x)) t.push('cs');
    if (/business|manage|account|financ|market|commerce|econom|banking/.test(x)) t.push('biz');
    if (/engineer|mechanic|electr|mechatron/.test(x)) t.push('eng');
    if (/civil|construct|survey/.test(x)) t.push('civil', 'qs');
    if (/architect/.test(x)) t.push('arch');
    if (/medic|mbbs|nurs|pharm|health|laborator/.test(x)) t.push('health');
    if (/\blaw\b|llb/.test(x)) t.push('law');
    if (/english|psycholog|educat|media|communicat|arts/.test(x)) t.push('lit', 'psy', 'edu', 'media');
    if (/science|physic|chem|bio|math|stat/.test(x)) t.push('sci');
    return t;
  }
  function relevant(c, code, d) {
    if (c.lv !== code) return false;
    if (code === 'CHILD') { var a = parseInt(d, 10); return isNaN(a) || (a >= (c.minA || 0) && a <= (c.maxA || 99)); }
    if (code === 'SCHOOL') { var g = parseInt(d, 10); return isNaN(g) || (g >= (c.minG || 0) && g <= (c.maxG || 99)); }
    if (code === 'AL') { var st = streamOf(d), ss = c.streams || ['ALL']; return !st || ss.indexOf('ALL') >= 0 || ss.indexOf(st) >= 0; }
    var tg = groupsOf(d);
    var cg = c.g || ['GEN'];
    return !tg.length || cg.indexOf('GEN') >= 0 || cg.some(function (x) { return tg.indexOf(x) >= 0; });
  }
  LH.me = me;
  /* ---------- admin changes (add / edit / delete a course) ----------
     The admin's changes are kept as an "overlay" on top of the built-in catalogue, so every page of this browser
     (students too) sees them. Stored in the database (table app_data, shared key courses-overlay). */
  function overlay() {
    var v = LH.load('courses-overlay', null);          /* shared value in the database (table app_data) */
    if (v && v.edited && v.added && v.deleted) return v;
    return {edited: {}, added: [], deleted: []};
  }
  LH.allCourses = function () {
    var ov = overlay(), gone = {}; ov.deleted.forEach(function (id) { gone[id] = 1; });
    var out = RAW.filter(function (c) { return !gone[c.id]; }).map(function (c) { return Object.assign({}, ov.edited[c.id] || c); });
    ov.added.forEach(function (c) { out.push(Object.assign({}, c)); });
    return out;
  };
  /* saves the admin's full course list (stores only the difference to the built-in catalogue) */
  LH.saveCourses = function (list) {
    var base = {}, have = {}, ov = {edited: {}, added: [], deleted: []};
    RAW.forEach(function (c) { base[c.id] = c; });
    list.forEach(function (c) {
      have[c.id] = 1;
      if (!base[c.id]) ov.added.push(c); else if (JSON.stringify(c) !== JSON.stringify(base[c.id])) ov.edited[c.id] = c;
    });
    RAW.forEach(function (c) { if (!have[c.id]) ov.deleted.push(c.id); });
    LH.save('courses-overlay', ov);                    /* saved in the database for every user */
  };
  LH.resetCourses = function () { LH.save('courses-overlay', {edited: {}, added: [], deleted: []}); };
  LH.LEVELS = [{code: 'CHILD', name: 'Child (3 - 7)', tab: 'Child', icon: '🧒'}, {code: 'SCHOOL', name: 'Grade 1 - 11', tab: 'Grade 1 - 11', icon: '🎒'},
               {code: 'AL', name: 'A/L', tab: 'A/L', icon: '📚'}, {code: 'UNDERGRAD', name: 'Undergraduate', tab: 'Undergraduate', icon: '🎓'}];
  /* the "who is this course for" fields every level needs (used when the admin adds a course or changes its level) */
  LH.levelFields = function (lv) {
    return lv === 'CHILD' ? {minA: 3, maxA: 7} : lv === 'SCHOOL' ? {minG: 1, maxG: 11} : lv === 'AL' ? {streams: ['ALL']} : {g: ['GEN']};
  };
  LH.levelPool = function (lv) { return POOL[lv] || POOL.UNDERGRAD; };
  LH.courses = function () {
    var u = me(), all = LH.allCourses();
    if (u.admin || !LEVEL_NAME[u.level]) return all;
    var mine = all.filter(function (c) { return relevant(c, u.level, u.detail); });
    return mine.length ? mine : all.filter(function (c) { return c.lv === u.level; });
  };
  /* learner level (CHILD / SCHOOL / AL / UNDERGRAD) of a course, found by its name ('' when the course no longer exists) */
  LH.courseLevel = function (name) {
    var all = LH.allCourses();
    for (var i = 0; i < all.length; i++) if (all[i].name === name) return all[i].lv;
    return '';
  };
  /* every course of one learner level (admin pickers) */
  LH.levelCourses = function (code) {
    return LH.allCourses().filter(function (c) { return c.lv === code; }).sort(function (a, b) { return a.name.localeCompare(b.name); });
  };
  /* Starter assignments, 3 for every learner level. Used until the admin changes the list for the first time.
     The ids (1..12) never change, so a submission made against a starter assignment stays valid once the admin saves the list. */
  LH.seedLevelAssignments = function () {
    var out = [], MARKS = {CHILD: 10, SCHOOL: 25, AL: 50, UNDERGRAD: 100}, DUE = [9, 16, 23];
    LH.LEVELS.forEach(function (l, li) {
      /* the courses open to the MOST students of this level come first, so (nearly) every student gets the starter assignments */
      var breadth = function (c) {
        return l.code === 'CHILD' ? (c.maxA || 99) - (c.minA || 0) : l.code === 'SCHOOL' ? (c.maxG || 99) - (c.minG || 0)
             : l.code === 'AL' ? ((c.streams || ['ALL']).indexOf('ALL') >= 0 ? 9 : c.streams.length) : ((c.g || ['GEN']).indexOf('GEN') >= 0 ? 9 : c.g.length);
      };
      var cs = LH.allCourses().filter(function (c) { return c.lv === l.code; }).map(function (c, i) { return {c: c, i: i, b: breadth(c)}; })
        .sort(function (x, y) { return y.b - x.b || x.i - y.i; }).map(function (x) { return x.c; });
      for (var k = 0; k < 3 && cs.length; k++) {
        var c = cs[k % cs.length], t = c.topics[k % c.topics.length];
        out.push({id: li * 3 + k + 1, lv: l.code, course: c.name, title: (l.code === 'CHILD' ? 'Activity: ' : 'Assignment: ') + t, due: LH.addDays(DUE[k]), marks: MARKS[l.code],
          desc: l.code === 'CHILD' ? 'Do this fun activity with a parent and upload a photo of your work.' : 'Complete the tasks on "' + t + '" and upload your answers.'});
      }
    });
    return out;
  };
  LH.price = function (c) { return c.fee > 0 ? LH.money(c.fee) : 'FREE'; };
  LH.levelName = function (code) { return LEVEL_NAME[code] || code; };
  LH.levelIcon = function (code) { return LEVEL_ICON[code] || ''; };
  LH.names = function () { return LH.courses().map(function (c) { return c.name; }); };
  LH.defaultEnrolled = function () {
    return LH.courses().filter(function (c) { return !c.free && c.seats - c.taken > 1; }).slice(0, 2).map(function (c, i) { return {id: c.id, date: LH.addDays(-40 + i * 12), progress: [62, 35][i]}; });
  };
  /* show "Courses for Grade 8" under the page title */
  LH.levelNote = function () {
    var u = me(), hero = document.querySelector('.mod-hero');
    if (!hero || document.getElementById('levelNote')) return;
    var n = document.createElement('div'); n.id = 'levelNote'; n.className = 'level-note';
    if (u.admin) n.innerHTML = '<span>🛡</span> Admin view &ndash; courses of <strong>all learner levels</strong>';
    else if (LEVEL_NAME[u.level]) {
      var d = u.level === 'CHILD' ? (u.detail ? 'Age ' + u.detail : 'Child') : u.level === 'SCHOOL' ? (u.detail ? 'Grade ' + u.detail : 'Grade 1 - 11') : u.level === 'AL' ? 'A/L' + (u.detail ? ' - ' + u.detail : '') : (u.detail || 'Undergraduate');
      n.innerHTML = '<span>' + LEVEL_ICON[u.level] + '</span> Courses chosen for you: <strong>' + LH.esc(d) + '</strong>';
    } else return;
    hero.parentNode.insertBefore(n, hero.nextSibling);
  };

  /* ---------- sample data that follows the courses ---------- */
  var NAMES = ['Nimali Perera', 'Kasun Fernando', 'Dilini Jayasinghe', 'Tharindu Silva', 'Ishara Wickramasinghe', 'Sanduni Rathnayake', 'Mahesh Gunawardena', 'Amaya Dissanayake'];
  var KIDS = ['Amaya', 'Sithum', 'Nethli', 'Dinul', 'Yuhani', 'Raveen', 'Senuli', 'Kavin'];
  var REV = [
    [5, 'Excellent course', 'Everything in "%c" was explained clearly and the lessons were easy to follow.'],
    [4, 'Very helpful', 'Good pace and lots of practice in "%c". I would like a few more examples.'],
    [5, 'Highly recommended', '"%c" made a hard topic simple. The teacher is patient and encouraging.'],
    [3, 'Good, but could improve', 'The content of "%c" is good, but some lessons felt rushed near the end.'],
    [4, 'Great teacher', 'The teacher of "%c" answers every question. The notes were very useful.'],
    [5, 'My marks improved', 'After joining "%c" I feel much more confident and my results improved.'],
    [2, 'Needs better audio', 'The material in "%c" is fine but some recordings have low volume.'],
    [5, 'Loved every lesson', 'Fun, clear and well organised. "%c" is worth every rupee.']
  ];
  LH.seedReviews = function (courses) {
    var u = me(), child = u.level === 'CHILD';
    return REV.map(function (r, i) {
      var c = courses[i % courses.length], nm = child ? 'Parent of ' + KIDS[i] : NAMES[i];
      return {id: i + 1, uid: 'X' + i, name: nm, course: c.name, rating: r[0], title: r[1], text: r[2].replace('%c', c.name), date: LH.addDays(-3 - i * 6), helpful: [14, 9, 21, 5, 7, 12, 3, 17][i]};
    });
  };
  LH.seedNotes = function (courses) {
    var u = me(), child = u.level === 'CHILD', out = [], id = 1, types = child ? ['video', 'pdf'] : ['pdf', 'slides', 'video', 'link'];
    courses.slice(0, 8).forEach(function (c, i) {
      [0, 1].forEach(function (k) {
        var t = c.topics[(i + k) % c.topics.length], type = types[(i + k) % types.length];
        out.push({id: id++, title: (child ? (type === 'video' ? 'Watch: ' : 'Worksheet: ') : '') + t + (child ? '' : (type === 'pdf' ? ' - Notes' : type === 'slides' ? ' - Slides' : type === 'video' ? ' - Lecture' : ' - Useful link')),
          course: c.name, type: type, size: type === 'video' ? (8 + i * 3) + ' min' : type === 'link' ? 'Website' : (1 + (i + k) % 5) + '.' + ((i * 3 + k) % 9) + ' MB', date: LH.addDays(-2 - i * 3 - k), down: 40 + (i * 37 + k * 11) % 260,
          desc: child ? 'Fun activity for little learners.' : 'Study material for "' + c.name + '".'});
      });
    });
    return out;
  };
  LH.seedAssignments = function (courses) {
    var u = me(), child = u.level === 'CHILD', marks = child ? 10 : u.level === 'SCHOOL' ? 25 : u.level === 'AL' ? 50 : 100;
    var plan = [['todo', 4], ['todo', 9], ['todo', -3], ['submitted', -6], ['graded', -14], ['todo', 2]], out = [];
    plan.forEach(function (p, i) {
      var c = courses[i % courses.length], t = c.topics[i % c.topics.length], a = {id: i + 1, title: (child ? 'Activity: ' : 'Assignment: ') + t, course: c.name, due: LH.addDays(p[1]), marks: marks, status: p[0],
        desc: child ? 'Do this fun activity with a parent and upload a photo of your work.' : 'Complete the tasks on "' + t + '" and upload your answers.'};
      if (p[0] !== 'todo') { a.submitted = LH.addDays(p[1] - 1); a.file = 'my-work-' + (i + 1) + '.pdf'; }
      if (p[0] === 'graded') { a.score = Math.round(marks * 0.86); a.feedback = 'Well done! Keep practising to improve even more.'; }
      out.push(a);
    });
    return out;
  };
  LH.seedPayments = function (courses, enrolled) {
    var by = function (id) { return courses.filter(function (c) { return c.id === id; })[0]; };
    var mine = enrolled.map(function (e) { return by(e.id); }).filter(function (c) { return c && !c.free; }), other = courses.filter(function (c) { return !c.free && !enrolled.some(function (e) { return e.id === c.id; }); });
    var pend = [], hist = [], n = 1042;
    if (other[0]) pend.push({id: 'INV-' + (n++), course: other[0].name, desc: 'Course fee - full payment', amount: other[0].fee, due: LH.addDays(5)});
    if (mine[0]) pend.push({id: 'INV-' + (n++), course: mine[0].name, desc: 'Course fee - installment 2 of 2', amount: Math.round(mine[0].fee / 2), due: LH.addDays(-2)});
    pend.push({id: 'INV-' + (n++), course: 'Premium membership', desc: 'Monthly membership', amount: 1500, due: LH.addDays(12)});
    mine.forEach(function (c, i) {
      hist.push({rcpt: 'RCT-' + LH.addDays(-30 - i * 15).replace(/-/g, '') + '-01', course: c.name, desc: i ? 'Course fee - full payment' : 'Course fee - installment 1 of 2', amount: i ? c.fee : Math.round(c.fee / 2), date: LH.addDays(-30 - i * 15), method: ['Card', 'Bank transfer'][i % 2], ref: i ? 'Slip uploaded' : '**** 4821'});
    });
    return {pending: pend, history: hist};
  };
  /* ---------- admin: the courses that suit ONE student (same rule the student's own pages use) ---------- */
  LH.coursesFor = function (code, detail) {
    var all = LH.allCourses(), mine = all.filter(function (c) { return relevant(c, code, (detail || '').trim()); });
    return mine.length ? mine : all.filter(function (c) { return c.lv === code; });
  };
  /* ---------- admin demo data: enrollments + payments of the real students (roster = students from the database) ---------- */
  LH.seedAdminEnrollments = function (roster, startId) {
    var out = [], n = startId || 1, PROG = [62, 35, 100, 18, 80, 47];
    roster.filter(function (r) { return r.status !== 'INACTIVE'; }).forEach(function (r, k) {
      var list = LH.coursesFor(r.lv, r.detail), paid = list.filter(function (c) { return !c.free; }), free = list.filter(function (c) { return c.free; }), picks = [];
      if (paid.length) picks.push({c: paid[(k * 3) % paid.length], paid: true});
      if (paid.length > 1) picks.push({c: paid[(k * 3 + 5) % paid.length], paid: k % 3 === 0 ? false : true});
      if (free.length && k % 2 === 0) picks.push({c: free[k % free.length], paid: 'free'});
      var seen = {};
      picks.forEach(function (p, j) {
        if (seen[p.c.id]) return; seen[p.c.id] = 1;
        out.push({id: n++, sid: r.id, cid: p.c.id, date: LH.addDays(-60 + k * 4 + j * 9), progress: PROG[(k + j) % 6], paid: p.paid});
      });
    });
    return out;
  };
  LH.seedAdminPayments = function (roster, enrollments) {
    var by = {}; roster.forEach(function (r) { by[r.id] = r; });
    var cs = {}; LH.allCourses().forEach(function (c) { cs[c.id] = c; });
    var M = ['Card', 'Bank transfer', 'Online wallet'], out = [];
    enrollments.forEach(function (e) {
      var c = cs[e.cid], r = by[e.sid]; if (!c || !r || e.paid !== true) return;
      var m = M[e.id % 3], d4 = String(1000 + (e.id * 737) % 9000);
      out.push({rcpt: 'RCT-' + e.date.replace(/-/g, '') + '-' + String(e.id).padStart(3, '0'), sid: e.sid, course: c.name, desc: 'Course fee - full payment', amount: c.fee, date: e.date, method: m,
                ref: m === 'Card' ? '**** ' + d4 : m === 'Bank transfer' ? 'Slip: slip-' + e.sid + '.pdf' : '077 *** ' + d4});
    });
    return out;
  };
  /* ---------- new students: the admin lists were generated once, so students who registered later had no rows.
     This adds enrollments + payments for every active student that has none yet (runs when an admin page opens). ---------- */
  LH.syncAdminSeed = function (roster) {
    var enr = LH.load('adm-enr', null), pays = LH.load('adm-pay', null), seen = LH.load('adm-seen', null);
    var firstTime = !enr, changed = false;
    if (!enr) enr = [];
    if (!pays) pays = [];
    if (!seen) {                                   /* older data: students that already have a row count as handled */
      seen = [];
      enr.concat(pays).forEach(function (r) { if (r.sid && seen.indexOf(r.sid) < 0) seen.push(r.sid); });
      if (firstTime) seen = [];
    }
    var fresh = roster.filter(function (r) { return r.status !== 'INACTIVE' && seen.indexOf(r.id) < 0; });
    if (fresh.length || firstTime) {
      var next = enr.reduce(function (m, e) { return Math.max(m, e.id || 0); }, 0) + 1;
      var newEnr = LH.seedAdminEnrollments(fresh, next), newPays = LH.seedAdminPayments(roster, newEnr);
      enr = enr.concat(newEnr); pays = pays.concat(newPays);
      fresh.forEach(function (r) { seen.push(r.id); });
      changed = true;
    }
    if (changed || firstTime) { LH.save('adm-enr', enr); LH.save('adm-pay', pays); LH.save('adm-seen', seen); }
    return {enr: enr, pays: pays};
  };
  document.addEventListener('DOMContentLoaded', function () { LH.levelNote(); });
})(window.LH);
