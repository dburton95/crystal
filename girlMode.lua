local girlMode = {}

function girlMode.init(mod)

  local textChanges = {
  -- GEN 1 -----------
  -- -----------------
    _RedsHouse1FMomWakeUpText = "MOM: Right.\nAll girls leave\vhome some day.\vIt said so on TV.\fPROF.OAK, next\ndoor, is looking\vfor you.",
    _SaffronGateGuardImParchedText = "Whoa, lady!\nI'm parched!\v...\vHuh? I can have\vthis drink?\vGee, thanks!",
    _Route9Hiker3BattleText = "Hahahaha!\nCome on, lady!",
    _SSAnne1FRoomsGirl1Text = "Waitress, I would\nlike a cherry pie\vplease!",
    _Route14Biker2AfterBattleText = "Raising POKéMON\nis a drag.",
    _SSTicketNoRoomText = "You've got too\nmuch stuff, lady!",
    _BillsHouseBillCheckOutMyRarePokemonText = "BILL: Look, lady,\njust check out\vsome of my rare\vPOKéMON on my PC!",
    _BillsHouseBillThankYouText = "BILL: Yeehah!\nThanks, lady! I\vowe you one!\fSo, did you come\nto see my POKéMON\vcollection?\vYou didn't?\vThat's a bummer.\fI've got to thank\nyou... Oh here,\vmaybe this'll do.",

  -- GEN 2 -------------
  -- -------------------

  -- CRYSTAL --------------------
  -- Same lines as the Gold/Silver keys below, keyed to Crystal's own text
  -- addresses. Crystal's text layout doesn't match Gold/Silver's, so these
  -- were matched by content against Crystal's extracted text data, not
  -- copied from the Gold keys. Two lines (4c:5009, 57:4d49) had no
  -- confirmed match and are left out rather than guessed. The three
  -- Copycat lines below aren't from a Gold key at all -- Crystal-only
  -- content, found via a systematic audit of every native gender check
  -- in pret/pokecrystal's maps/ (see the Copycat comment below). -Elvie
  -- --------------------------------
    ["64:40b0"] = "Hiya, kid! I\nsee you're new in\011MAHOGANY TOWN.\012Since you're new,\nyou should try a\012yummy RAGECANDY-\nBAR!\012Right now, it can\nbe yours for just\011¥300! Want one?",
    ["69:57ba"] = "Let's see…\012…DARK CAVE leads\nto another road…\012That's good to\nknow.\012Thanks for bring-\ning this to me.\012My friend's a good\nguy, and you're \011swell too!\012I'd like to do\nsomething good in\011return too!\012I know! I want you\nto have this!",
    ["6b:4130"] = "Whoa! You've\ngot more zip.",
    ["1e:4609"] = "You're a tough\n kid.",
    ["1e:4743"] = "IRENE: Kyaaah!\nSomeone found us!",
    ["1e:4765"] = "IRENE: Ohhhh!\nToo strong!",
    ["27:4fe1"] = "How'd you like my\nMOOMOO MILK?\012It's my pride and\njoy, lady.\012Give it to POKéMON\nto restore HP!\012I'll give it to ya\nfer just ¥500.",
    ["26:5891"] = "Lassie! If you can\ndefeat all the\012KIMONO GIRLS, I'll\ngive you a gift.",
    ["6a:7759"] = "Yo!\012… Huh? It's over\nalready?\012Sorry, sorry!\012CINNABAR GYM was\ngone, so I didn't\012know where to find\nyou.\012But, hey, you're\nplenty strong even\012without my advice.\nI knew you'd win!",
    ["66:6cd2"] = "Hold it there,\nkiddo!\012The toll is ¥1000\nto go through.",
    ["66:6d0a"] = "Thank you very much!",
    ["63:5f93"] = "The SLOWPOKE came\nback, and you even\011found FARFETCH'D.\012You're the cool-\nest, lady!",
    ["1a:5ddd"] = "Excuse me, kid!\nCan you do a guy\011a favor?\012Can you take this\nPOKéMON with MAIL\011to my friend?\012He's on ROUTE 31.",
    ["1a:5e48"] = "You will? Perfect!\nThanks, kid!\012My pal's a chubby\nguy who snoozes\011all the time.\012You'll recognize\nhim right away!",
    ["1a:5f8b"] = "Thanks, kid! You\nmade the delivery\011for me!\012Here's something\nfor your trouble!",
    ["15:51ed"] = "May I see your\nrail PASS, please?\012OK. Right this\nway, please.",
    ["64:6142"] = "SURGE: Hey, you\nlittle tyke!\012I have to hand it\nto you. It may not\012be very smart to\nchallenge me, but\011it takes guts!\012When it comes to\nelectric POKéMON,\011I'm number one!\012I've never lost on\nthe battlefield.\012I'll zap you just\nlike I did my\011enemies in war!",
    ["64:6238"] = "SURGE: Arrrgh!\nYou are strong!\012OK, kid. You get\nTHUNDERBADGE!",
    ["60:54a6"] = "LANCE: It's been a\nlong time since I\011last came here.\012This is where we\nhonor the LEAGUE\012CHAMPIONS for all\neternity.\012Their courageous\nPOKéMON are also\011inducted.\012Here today, we\nwitnessed the rise\012of a new LEAGUE\nCHAMPION--a\012trainer who feels\ncompassion for,\012and trust in, her\nPOKéMON.\012A trainer who\nsucceeded through\012perseverance and\ndetermination.\012The new LEAGUE\nCHAMPION who has\012all the makings\nof greatness!\012{PLAYER}, allow me\nto register you\012and your partners\nas CHAMPIONS!",
    ["1d:4ada"] = "May I see your\nS.S.TICKET?",
    ["1d:4b11"] = "{PLAYER} flashed\nthe S.S.TICKET.\012That's it.\nThank you!",
    ["1d:4f8b"] = "May I see your\nS.S.TICKET?",
    ["1d:4fc2"] = "{PLAYER} flashed\nthe S.S.TICKET.\012That's it.\nThank you!",
    ["1d:5412"] = "Whoa!\012Excuse me.\nI was in a hurry!\012My granddaughter\nis missing!\012She's just a wee\ngirl. If you see\012her, please let me\nknow!",
    ["1d:5937"] = "I give up.\nYou don't have to\012look. Just forget\nabout it!",
    ["1d:5bbd"] = "Ooh, wow. You're\ntough!",
    ["1d:6284"] = "Grandpa, here I\nam! I was playing\012with the CAPTAIN\nand this big girl!",
    ["1d:687b"] = "Hey, lady. Could I\nget you to look\011for my buddy?\012He's goofing off\nsomewhere, that\011lazy bum!\012I want to go find\nhim, but I'm on\011duty right now.",
    ["26:6a7b"] = "BLUE: Yo! Finally\ngot here, huh?\012I wasn't in the\nmood at CINNABAR,\012but now I'm ready\nto battle you.\012…\012You're telling me\nyou conquered all\011the GYMS in JOHTO?\012Heh! JOHTO's GYMS\nmust be pretty\011pathetic then.\012Hey, don't worry\nabout it.\012I'll know if you\nare good or not by\012battling you right\nnow.\012Ready, JOHTO CHAMP?",
    ["26:751d"] = "I'm sorry.\nThis would be your\012second time today.\nYou're permitted\012to enter just once\na day.",
    ["62:6917"] = "May I see your\nrail PASS, please?\012OK. Right this\nway, please.",
    ["4b:4ff1"] = "Whoa! You've\ngot more zip.",
    ["55:440c"] = "The SLOWPOKE came\nback, and you even\011found FARFETCH'D.\012You're the cool-\nest, lady!",
    ["4b:550f"] = "You're a tough\n kid.",    
    ["4b:5649"] = "IRENE: Kyaaah!\nSomeone found us!",    
    ["4b:5669"] = "IRENE: Ohhhh!\nToo strong!",    
    ["57:5164"] = "May I see your\nrail PASS, please?\012OK. Right this\nway, please.",   
    ["61:4cb3"] = "May I see your\nrail PASS, please?\012OK. Right this\nway, please.",    
    -- Copycat mirrors the player's own way of talking, with fully separate
    -- male/female dialogue (not a single swapped word) -- found via a
    -- systematic audit of every ENGINE_PLAYER_IS_FEMALE check in
    -- pret/pokecrystal's maps/, cross-checked against Crystal's own
    -- extracted text. Since our gender bypass always resolves male, her
    -- male lines are what always display; these replace them with her
    -- real female lines. -Elvie
    ["62:6fda"] = "{PLAYER}: Hi. You\nmust like POKéMON.\012{PLAYER}: No, not\nme. I asked you.\012{PLAYER}: Pardon?\nYou're weird!",
    ["62:7064"] = "{PLAYER}: Hi. Did\nyou really lose\011your POKé DOLL?\012{PLAYER}: You'll\nreally give me a\012rail PASS if I\nfind it for you?\012{PLAYER}: Sure,\nI'll look for it!\012You think you lost\nit when you were\011in VERMILION?",
    ["62:7298"] = "{PLAYER}: Thank you\nfor the rail PASS!\012{PLAYER}: …Pardon?\012{PLAYER}: Is it\nreally that fun to\012copy what I say\nand do?",
    ["56:5a70"] = "Excuse me, kid!\nCan you do a guy\011a favor?\012Can you take this\nPOKéMON with MAIL\011to my friend?\012He's on ROUTE 31.",    
    ["56:5adb"] = "You will? Perfect!\nThanks, kid!\012My pal's a chubby\nguy who snoozes\011all the time.\012You'll recognize\nhim right away!",    
    ["4a:5cd9"] = "Let's see…\012…DARK CAVE leads\nto another road…\012That's good to\nknow.\012Thanks for bring-\ning this to me.\012My friend's a good\nguy, and you're \011swell too!\012I'd like to do\nsomething good in\011return too!\012I know! I want you\nto have this!",    
    ["56:5c1e"] = "Thanks, kid! You\nmade the delivery\011for me!\012Here's something\nfor your trouble!",    
    ["57:4d49"] = "BILL: I knew it!\nWay to go, hero!\012You're the real\ndeal!\012OK, I'm counting\non you. Take good\011care of it.",   
    ["52:4c1b"] = "Lassie! If you can\ndefeat all the\012KIMONO GIRLS, I'll\ngive you a gift.", 
    ["51:4fb7"] = "How'd you like my\nMOOMOO MILK?\012It's my pride and\njoy, lady.\012Give it to POKéMON\nto restore HP!\012I'll give it to ya\nfer just ¥500.",    
    ["4c:5009"] = "A young girl like\nyou should swim.\012Don't SURF on your\nPOKéMON.",    
    ["49:4b65"] = "Hiya, kid! I\nsee you're new in\011MAHOGANY TOWN.\012Since you're new,\nyou should try a\012yummy RAGECANDY-\nBAR!\012Right now, it can\nbe yours for just\011¥300! Want one?",    
    ["53:5ca8"] = "Hold it there,\nkiddo!\012The toll is ¥1000\nto go through.",    
    ["53:5ce1"] = "Thank you very much!",    
    ["5a:5d51"] = "LANCE: It's been a\nlong time since I\011last came here.\012This is where we\nhonor the LEAGUE\012CHAMPIONS for all\neternity.\012Their courageous\nPOKéMON are also\011inducted.\012Here today, we\nwitnessed the rise\012of a new LEAGUE\nCHAMPION--a\012trainer who feels\ncompassion for,\012and trust in, her\nPOKéMON.\012A trainer who\nsucceeded through\012perseverance and\ndetermination.\012The new LEAGUE\nCHAMPION who has\012all the makings\nof greatness!\012{PLAYER}, allow me\nto register you\012and your partners\nas CHAMPIONS!",    
    ["5b:4238"] = "May I see your\nS.S.TICKET?",    
    ["5b:46f3"] = "May I see your\nS.S.TICKET?",    
    ["5b:4274"] = "{PLAYER} flashed\nthe S.S.TICKET.\012That's it.\nThank you!",    
    ["5b:472f"] = "{PLAYER} flashed\nthe S.S.TICKET.\012That's it.\nThank you!",    
    ["5b:4b84"] = "Whoa!\012Excuse me.\nI was in a hurry!\012My granddaughter\nis missing!\012She's just a wee\ngirl. If you see\012her, please let me\nknow!",    
    ["5b:5f4b"] = "Hey, lady. Could I\nget you to look\011for my buddy?\012He's goofing off\nsomewhere, that\011lazy bum!\012I want to go find\nhim, but I'm on\011duty right now.",    
    ["5b:599b"] = "Grandpa, here I\nam! I was playing\012with the CAPTAIN\nand this big girl!",    
    ["5b:5329"] = "Ooh, wow. You're\ntough!",    
    ["5b:50ae"] = "I give up.\nYou don't have to\012look. Just forget\nabout it!",    
    ["59:4c99"] = "SURGE: Hey, you\nlittle tyke!\012I have to hand it\nto you. It may not\012be very smart to\nchallenge me, but\011it takes guts!\012When it comes to\nelectric POKéMON,\011I'm number one!\012I've never lost on\nthe battlefield.\012I'll zap you just\nlike I did my\011enemies in war!",    
    ["59:4d8a"] = "SURGE: Arrrgh!\nYou are strong!\012OK, kid. You get\nTHUNDERBADGE!",    
    ["5f:4af7"] = "I'm sorry.\nThis would be your\012second time today.\nYou're permitted\012to enter just once\na day.",    
    ["53:53cb"] = "Yo!\012… Huh? It's over\nalready?\012Sorry, sorry!\012CINNABAR GYM was\ngone, so I didn't\012know where to find\nyou.\012But, hey, you're\nplenty strong even\012without my advice.\nI knew you'd win!",    
    ["5f:4057"] = "BLUE: Yo! Finally\ngot here, huh?\012I wasn't in the\nmood at CINNABAR,\012but now I'm ready\nto battle you.\012…\012You're telling me\nyou conquered all\011the GYMS in JOHTO?\012Heh! JOHTO's GYMS\nmust be pretty\011pathetic then.\012Hey, don't worry\nabout it.\012I'll know if you\nare good or not by\012battling you right\nnow.\012Ready, JOHTO CHAMP?",    
  }

  for label, text in pairs(textChanges) do
    mod.content.text:override(label, text)
  end

end

return girlMode
