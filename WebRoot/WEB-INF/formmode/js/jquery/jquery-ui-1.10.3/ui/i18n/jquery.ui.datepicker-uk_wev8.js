﻿/* Ukrainian (UTF-8) initialisation for the jQuery UI date picker plugin. */
/* Written by Maxim Drogobitskiy (maxdao@gmail.com). */
/* Corrected by Igor Milla (igor.fsp.milla@gmail.com). */
jQuery(function($){
	$.datepicker.regional['uk'] = {
		closeText: '袟邪泻褉懈褌懈',
		prevText: '&#x3C;',
		nextText: '&#x3E;',
		currentText: '小褜芯谐芯写薪褨',
		monthNames: ['小褨褔械薪褜','袥褞褌懈泄','袘械褉械蟹械薪褜','袣胁褨褌械薪褜','孝褉邪胁械薪褜','效械褉胁械薪褜',
		'袥懈锌械薪褜','小械褉锌械薪褜','袙械褉械褋械薪褜','袞芯胁褌械薪褜','袥懈褋褌芯锌邪写','袚褉褍写械薪褜'],
		monthNamesShort: ['小褨褔','袥褞褌','袘械褉','袣胁褨','孝褉邪','效械褉',
		'袥懈锌','小械褉','袙械褉','袞芯胁','袥懈褋','袚褉褍'],
		dayNames: ['薪械写褨谢褟','锌芯薪械写褨谢芯泻','胁褨胁褌芯褉芯泻','褋械褉械写邪','褔械褌胁械褉','锌鈥櫻徰傂叫秆喲?,'褋褍斜芯褌邪'],
		dayNamesShort: ['薪械写','锌薪写','胁褨胁','褋褉写','褔褌胁','锌褌薪','褋斜褌'],
		dayNamesMin: ['袧写','袩薪','袙褌','小褉','效褌','袩褌','小斜'],
		weekHeader: '孝懈卸',
		dateFormat: 'dd/mm/yy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	$.datepicker.setDefaults($.datepicker.regional['uk']);
});
