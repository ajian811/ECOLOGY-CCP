﻿/* Hindi initialisation for the jQuery UI date picker plugin. */
/* Written by Michael Dawart. */
jQuery(function($){
	$.datepicker.regional['hi'] = {
		closeText: '啶啶?,
		prevText: '啶た啶涏げ啶?,
		nextText: '啶呧啶侧ぞ',
		currentText: '啶嗋',
		monthNames: ['啶溹え啶掂ぐ啷€ ','啶ぐ啶掂ぐ啷€','啶ぞ啶班啶?,'啶呧お啷嵿ぐ啷囙げ','啶','啶溹啶?,
		'啶溹啶侧ぞ啶?,'啶呧啶膏啶?','啶膏た啶むぎ啷嵿が啶?,'啶呧啷嵿啷傕が啶?,'啶ㄠさ啶啶ぐ','啶︵た啶膏ぎ啷嵿が啶?],
		monthNamesShort: ['啶溹え', '啶ぐ', '啶ぞ啶班啶?, '啶呧お啷嵿ぐ啷囙げ', '啶', '啶溹啶?,
		'啶溹啶侧ぞ啶?, '啶呧', '啶膏た啶?, '啶呧啷嵿', '啶ㄠさ', '啶︵た'],
		dayNames: ['啶班さ啶苦さ啶距ぐ', '啶膏啶さ啶距ぐ', '啶啶椸げ啶掂ぞ啶?, '啶啶оさ啶距ぐ', '啶椸啶班啶掂ぞ啶?, '啶多啶曕啶班さ啶距ぐ', '啶多え啶苦さ啶距ぐ'],
		dayNamesShort: ['啶班さ啶?, '啶膏啶?, '啶啶椸げ', '啶啶?, '啶椸啶班', '啶多啶曕啶?, '啶多え啶?],
		dayNamesMin: ['啶班さ啶?, '啶膏啶?, '啶啶椸げ', '啶啶?, '啶椸啶班', '啶多啶曕啶?, '啶多え啶?],
		weekHeader: '啶灌か啷嵿い啶?,
		dateFormat: 'dd/mm/yy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	$.datepicker.setDefaults($.datepicker.regional['hi']);
});
