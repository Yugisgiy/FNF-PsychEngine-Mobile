package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import objects.MenuCharacter;

import states.editors.MasterEditorMenu;
import options.OptionsState;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class MainMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var psychEngineVersion:String = '0.7.2h'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	var curSelCred:Int = 0;
	public static var inicial:Bool = false;
	var goAway:Bool = false;

	var credBG:FlxSprite;

	var scoreText:FlxText;
	var someStuffsICON:FlxTypedGroup<FlxSprite>;
	private var creditsStuff:Array<Array<String>> = [];

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bg:FlxSprite;
	var bgE:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	var shit:FlxSprite;
	var credPendejs:FlxSprite;
	var blackBGcred:FlxSprite;
	var transitionPaper:FlxSprite;

	var creditsSHOWING:Bool = false;

	var optionShit:Array<String> = [
		'play',
		'options',
		'credits'
	];
	var useMouse:Bool = true;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80);//.loadGraphic(Paths.image('logoBumpin'));
		bg.frames = Paths.getSparrowAtlas('bg');
		bg.animation.addByPrefix('idle', 'bgLoop', 2);
		bg.animation.play('idle');
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter(X);
		add(bg);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Thinking if it's a good idea... (In main menu)", null);
		#end

		shit = new FlxSprite(0,60);//.loadGraphic(Paths.image('logoBumpin'));
		shit.frames = Paths.getSparrowAtlas('libroPaper');
		shit.animation.addByPrefix('play', 'play', 10);
		shit.animation.addByPrefix('options', 'options', 10);
		shit.animation.addByPrefix('credits', 'credits', 10);
		shit.animation.play('play');
		shit.antialiasing = ClientPrefs.data.antialiasing;
		shit.screenCenter(X);
		shit.scale.x = 0.9;
		shit.scale.y = 0.9;
		add(shit);



		var defaultList:Array<Array<String>> = [ 
			['redblack','https://twitter.com/RedBlack_Master'],
			['charry','https://x.com/Chrisdeadwtf?t=00C08bCDWvcnDzYhtzom6g&s=09'],
			['kimihito','https://twitter.com/cen55537226'],
			['generic','https://twitter.com/xd_generico'],
			['santiago','https://www.youtube.com/@dee-thamendoza'],
			['MisaFenix','https://x.com/Zardy459011601?t=vDuebk60yy80OGoKbwvX7w&s=09'],
			['LeoEkisde','https://x.com/Leoekisdeomg?t=hJLP5etsCOAzaxxaHSgNaA&s=09'],
			['redby2006','https://twitter.com/Redby2006'],
			['denott','https://twitter.com/DENOTTOG'],
		];
		
		for(i in defaultList) {
			creditsStuff.push(i);
		}

		credBG = new FlxSprite().loadGraphic(Paths.image('creditsBanners/credBG'));
		credBG.alpha = 0;
		add(credBG);

		credPendejs = new FlxSprite().loadGraphic(Paths.image('creditsBanners/losPendej'));
		credPendejs.alpha = 0;
		add(credPendejs);
		credPendejs.screenCenter();

		blackBGcred = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBGcred.alpha = 0;
		add(blackBGcred);



		someStuffsICON = new FlxTypedGroup<FlxSprite>();
		add(someStuffsICON);

		for (i in 0...creditsStuff.length)
		{
			var iconEx:FlxSprite = new FlxSprite(0,130+(i * 360)).loadGraphic(Paths.image('creditsBanners/'+creditsStuff[i][0]));
			iconEx.antialiasing = ClientPrefs.data.antialiasing;
			iconEx.alpha = 0;
			iconEx.scale.x = 0.7;iconEx.scale.y = 0.7;
			someStuffsICON.add(iconEx);
			iconEx.screenCenter(X);
			someStuffsICON.ID = i;
		}


		if (!inicial)
		{
			inicial = true;
			transitionPaper = new FlxSprite();
			transitionPaper.antialiasing = ClientPrefs.data.antialiasing;
			transitionPaper.frames = Paths.getSparrowAtlas('paper');
				
			transitionPaper.animation.addByPrefix('fade', "fade", 24);
			add(transitionPaper);

			new FlxTimer().start(1, function(tmr:FlxTimer){transitionPaper.animation.play('fade',false);});
			new FlxTimer().start(1.5, function(tmr:FlxTimer){transitionPaper.kill();});

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.4);
		}
		var daChoiceses:String = optionShit[curSelected];

		switch (daChoiceses)
		{
			case 'play':
				shit.animation.play('play');
			case 'options':
				shit.animation.play('options');
			case 'credits':
				shit.animation.play('credits');
		}
		super.create();
	}

	override function update(elapsed:Float)
	{

		#if desktop
			if (controls.justPressed('debug_1') && !creditsSHOWING)
			{
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		#end

		if (controls.UI_UP_P && curSelected == 2 && !creditsSHOWING)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

		if (controls.UI_DOWN_P && curSelected == 1 && !creditsSHOWING)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(1);
		}

		if (controls.UI_RIGHT_P && curSelected == 0 && !creditsSHOWING)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

		if (controls.UI_LEFT_P && curSelected != 0 && !creditsSHOWING)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(0);
		}
		
		if (controls.ACCEPT && !goAway && !creditsSHOWING)
		{
			var daChoice:String = optionShit[curSelected];

			switch (daChoice)
			{
				case 'play':
					_PLAY();
				case 'options':
					_OPTIONS();
				case 'credits':
					_CREDITS();
			}
		}

		if (controls.BACK && !goAway && creditsSHOWING)
		{
			creditsSHOWING = false;
			goAway = true;
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{goAway = false;});

			FlxG.sound.play(Paths.sound('cancelMenu'));

			someStuffsICON.forEach(function(duffpuff:FlxSprite)
				{FlxTween.tween(duffpuff, {alpha : 0}, 0.5, {ease: FlxEase.quartOut});});

			FlxTween.tween(credBG, {alpha : 0}, 0.5, {ease: FlxEase.quartOut});
			FlxTween.tween(credPendejs, {alpha : 0}, 0.5, {ease: FlxEase.quartOut});
			FlxTween.tween(blackBGcred, {alpha : 0}, 0.5, {ease: FlxEase.quartOut});
		}


		if (controls.UI_UP_P && creditsSHOWING && !goAway && curSelCred > 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItemCred(-1);
			}

		if (controls.UI_DOWN_P && creditsSHOWING && !goAway && curSelCred != 8)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItemCred(1);
		}

		if (controls.ACCEPT && !goAway && creditsSHOWING)
		{
			CoolUtil.browserLoad(creditsStuff[curSelCred][1]);
		}

		

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;


	function changeItem(huhE:Int = 0,reset:Int = 0)
	{
		curSelected += huhE;

		if (huhE == 0)
			curSelected = reset;

	
		if (curSelected >= optionShit.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = optionShit.length - 1;
	
	
		var daChoices:String = optionShit[curSelected];

		switch (daChoices)
		{
			case 'play':
				shit.animation.play('play');
			case 'options':
				shit.animation.play('options');
			case 'credits':
				shit.animation.play('credits');
		}
			
	}

	function changeItemCred(huh:Int = 0,dir:Int = 0)
	{
		curSelCred += huh;

		if (huh >= 0)
		{
			someStuffsICON.forEach(function(duffpuff:FlxSprite)
				{FlxTween.tween(duffpuff, {y : duffpuff.y-360}, 0.3, {ease: FlxEase.quartOut});});
		}

		if (huh <= 0)
		{
			someStuffsICON.forEach(function(duffpuff:FlxSprite)
				{FlxTween.tween(duffpuff, {y : duffpuff.y+360}, 0.3, {ease: FlxEase.quartOut});});
		}
				
		goAway = true;
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{goAway = false;});

	}


	function _CREDITS() 
	{
		creditsSHOWING = true;
		goAway = true;
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{goAway = false;});

		FlxG.sound.play(Paths.sound('confirmMenu'));

		someStuffsICON.forEach(function(duffpuff:FlxSprite)
			{FlxTween.tween(duffpuff, {alpha : 1}, 0.5, {ease: FlxEase.quartOut});});

		FlxTween.tween(credBG, {alpha : 0.8}, 0.5, {ease: FlxEase.quartOut});
		FlxTween.tween(credPendejs, {alpha : 1}, 0.5, {ease: FlxEase.quartOut});
		FlxTween.tween(blackBGcred, {alpha : 0.4}, 0.5, {ease: FlxEase.quartOut});
	}

	function _OPTIONS() 
	{
		goAway = true;
		FlxTween.tween(shit, {"scale.x" : 0,"scale.y" : 0,alpha : 0}, 1.5, {ease: FlxEase.quartInOut});
		FlxG.sound.play(Paths.sound('confirmMenu'));
		
		new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{LoadingState.loadAndSwitchState(new OptionsState());});
	}

	function _PLAY()
	{
		goAway = true;

		FlxTween.tween(shit, {"scale.x" : 0,"scale.y" : 0}, 2.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(FlxG.camera, {zoom : 3}, 3, {ease: FlxEase.quartInOut});

		try
		{
			PlayState.SONG = Song.loadFromJson(Paths.formatToSongPath('Math-') + Difficulty.getDefault(), Paths.formatToSongPath('Math'));
			PlayState.isStoryMode = true;
		}
		catch(e:Dynamic)
		{
			trace('ERROR! $e');
			var errorStr:String = e.toString();
			if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxG.sound.music.volume = 0;

		//-----------TICKS----------------------------------------------------
		new FlxTimer().start(0.6, function(tmr:FlxTimer)//ULTIMO TICK
		{
			LoadingState.loadAndSwitchState(new PlayState());
			FreeplayState.destroyFreeplayVocals();
		});
		//-----------END TICKS----------------------------------------------------
			
		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

}