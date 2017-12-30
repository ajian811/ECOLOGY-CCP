﻿/* Japanese initialisation for the jQuery UI date picker plugin. */
/* Written by Kentaro SATO (kentaro@ranvis.com). */
jQuery(function($){
	$.datepicker.regional['ja'] = {
		closeText: '闁夈仒銈?,
		prevText: '&#x3C;鍓?,
		nextText: '娆?#x3E;',
		currentText: '浠婃棩',
		monthNames: ['1鏈?,'2鏈?,'3鏈?,'4鏈?,'5鏈?,'6鏈?,
		'7鏈?,'8鏈?,'9鏈?,'10鏈?,'11鏈?,'12鏈?],
		monthNamesShort: ['1鏈?,'2鏈?,'3鏈?,'4鏈?,'5鏈?,'6鏈?,
		'7鏈?,'8鏈?,'9鏈?,'10鏈?,'11鏈?,'12鏈?],
		dayNames: ['鏃ユ洔鏃?,'鏈堟洔鏃?,'鐏洔鏃?,'姘存洔鏃?,'鏈ㄦ洔鏃?,'閲戞洔鏃?,'鍦熸洔鏃?],
		dayNamesShort: ['鏃?,'鏈?,'鐏?,'姘?,'鏈?,'閲?,'鍦?],
		dayNamesMin: ['鏃?,'鏈?,'鐏?,'姘?,'鏈?,'閲?,'鍦?],
		weekHeader: '閫?,
		dateFormat: 'yy/mm/dd',
		firstDay: 0,
		isRTL: false,
		showMonthAfterYear: true,
		yearSuffix: '骞?};
	$.datepicker.setDefaults($.datepicker.regional['ja']);
});
