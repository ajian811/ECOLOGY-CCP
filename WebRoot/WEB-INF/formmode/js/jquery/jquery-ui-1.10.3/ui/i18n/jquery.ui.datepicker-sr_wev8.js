﻿/* Serbian i18n for the jQuery UI date picker plugin. */
/* Written by Dejan Dimi膰. */
jQuery(function($){
	$.datepicker.regional['sr'] = {
		closeText: '袟邪褌胁芯褉懈',
		prevText: '&#x3C;',
		nextText: '&#x3E;',
		currentText: '袛邪薪邪褋',
		monthNames: ['袌邪薪褍邪褉','肖械斜褉褍邪褉','袦邪褉褌','袗锌褉懈谢','袦邪褬','袌褍薪',
		'袌褍谢','袗胁谐褍褋褌','小械锌褌械屑斜邪褉','袨泻褌芯斜邪褉','袧芯胁械屑斜邪褉','袛械褑械屑斜邪褉'],
		monthNamesShort: ['袌邪薪','肖械斜','袦邪褉','袗锌褉','袦邪褬','袌褍薪',
		'袌褍谢','袗胁谐','小械锌','袨泻褌','袧芯胁','袛械褑'],
		dayNames: ['袧械写械褭邪','袩芯薪械写械褭邪泻','校褌芯褉邪泻','小褉械写邪','效械褌胁褉褌邪泻','袩械褌邪泻','小褍斜芯褌邪'],
		dayNamesShort: ['袧械写','袩芯薪','校褌芯','小褉械','效械褌','袩械褌','小褍斜'],
		dayNamesMin: ['袧械','袩芯','校褌','小褉','效械','袩械','小褍'],
		weekHeader: '小械写',
		dateFormat: 'dd.mm.yy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	$.datepicker.setDefaults($.datepicker.regional['sr']);
});
